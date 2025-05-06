#!/bin/bash

apk add yq || { echo "ERROR: Failed to install yq. Aborting." >&2; exit 1; }

log() {

    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

error_exit() {
    log "ERROR: $1"
}

command -v yq >/dev/null 2>&1 || error_exit "yq is required but not installed or not in PATH. Aborting."
command -v git >/dev/null 2>&2 || error_exit "git is required but not installed or not in PATH. Aborting."
command -v jq >/dev/null 2>&1 || error_exit "jq is required but not installed or not in PATH. Aborting."
command -v curl >/dev/null 2>&1 || error_exit "curl is required but not installed or not in PATH. Aborting." 

: "${GITHUB_API_TOKEN:?GITHUB_API_TOKEN is not set or empty}"
: "${GIT_USER_EMAIL:?GIT_USER_EMAIL is not set or empty}"
: "${GIT_USER_NAME:?GIT_USER_NAME is not set or empty}"
: "${CI_CD_EVENT:?CI_CD_EVENT is not set or empty}"

log "Setting Git user config"
git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"

REPO_OWNER=$(echo "$REPO_URL" | sed -E 's|https://github.com/([^/]+)/.*|\1|')
REPO_NAME=$(echo "$REPO_URL" | sed -E 's|https://github.com/[^/]+/([^/]+)\.git|\1|')
FULL_IMAGE_PATH=$(echo "$CI_CD_EVENT" | jq -r '.commonWorkflowRequest.dockerRepository')
IMAGE_TAG=$(echo "$CI_CD_EVENT" | jq -r '.commonWorkflowRequest.dockerImageTag')


IMAGE_NAME=$(echo "$FULL_IMAGE_PATH" | sed -E 's|.*/([^/]+)|\1|') 

log "Full Image path from event: $FULL_IMAGE_PATH"
log "Image Name to search for in YAML: $IMAGE_NAME"
log "New Image Tag: $IMAGE_TAG"

PREVIOUS_TAG="" 
CHANGES_MADE=false 

update_image() {
    local image_name="$1"        
    local new_tag="$2"           
    local file_to_change="$3"    
    local found_image_string=false 
    local update_required=false 

    log "Searching for image matching pattern '${image_name}:*' in file: $file_to_change"

    while IFS='=' read -r current_path current_value; do

        current_value=$(echo "$current_value" | xargs) 
        current_value="${current_value%\"}" 
        current_value="${current_value#\"}"

        if [[ "$current_value" == "${image_name}":* ]]; then
            found_image_string=true 

            local current_tag="${current_value##*:}" 

            log "Found  image : '$current_value' at path '.$current_path'"
            log "Extracted current tag: '$current_tag'"

            if [ "$current_tag" != "$new_tag" ]; then
                log "New tag '$new_tag'."
                update_required=true 
                PREVIOUS_TAG="$current_tag"

                local new_image_string="${image_name}:${new_tag}"

                log "Attempting to update path .$current_path in $file_to_change"
                if yq e ".${current_path} = \"${new_image_string}\"" -i "$file_to_change"; then
                     log "Successfully updated path .$current_path"
                     CHANGES_MADE=true 
                     break
                else
                     log "ERROR: Failed to update path .$current_path in file $file_to_change."

                fi
            else
                log "Image '$image_name' at path '.$current_path' already at desired version '$new_tag'."
                update_required=true 
                break 
            fi
        fi

    done < <(yq e '.. | select(tag == "!!str") | {(path | join(".")): .} | to_props' "$file_to_change" 2>/dev/null) 

    if ! $found_image_string; then
        log "Image matching pattern '${image_name}:*' was NOT found in $file_to_change. No changes made for this file."
    elif ! $update_required; then
         log "Image matching pattern '${image_name}:*' found, but update logic didn't flag update required. This is unexpected."
    fi
    
}

log "Cloning repository: ${REPO_URL}"

if ! git clone "https://${GITHUB_API_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"; then
    error_exit "Failed to clone repository ${REPO_URL}"
fi
cd "${REPO_NAME}" || error_exit "Failed to change directory to ${REPO_NAME}"
log "Changed directory to $(pwd)"

log "Fetching latest changes from origin"
if ! git fetch origin; then
    error_exit "Failed to fetch latest changes from origin"
fi

log "Checking out branch: ${BRANCH_NAME}"

if git ls-remote --exit-code --heads origin "$BRANCH_NAME" >/dev/null 2>&1; then
    log "Branch $BRANCH_NAME already exists remotely. Checking it out and pulling latest changes."
    if ! git checkout "$BRANCH_NAME"; then
        error_exit "Failed to checkout existing branch $BRANCH_NAME"
    fi
    log "Pulling latest changes for branch $BRANCH_NAME"
    if ! git pull origin "$BRANCH_NAME"; then
        error_exit "Failed to pull latest changes for branch $BRANCH_NAME"
    fi
else
    log "Branch $BRANCH_NAME does not exist remotely. Creating a new branch based on origin/main."

    if ! git rev-parse origin/main >/dev/null 2>&1; then
         error_exit "origin/main branch not found. Cannot create new branch $BRANCH_NAME."
    fi
    if ! git checkout -b "$BRANCH_NAME" origin/main; then
        error_exit "Failed to create new branch $BRANCH_NAME based on origin/main"
    fi
    log "Created new branch $BRANCH_NAME"
fi

log "Updating Image Tag in $IMAGE_LIST_FILE"

sed -i "s|^quay.io/devtron/${FULL_IMAGE_PATH}:.*|quay.io/devtron/${FULL_IMAGE_PATH}:${IMAGE_TAG}|" "$IMAGE_LIST_FILE"

update_image "$IMAGE_NAME" "$IMAGE_TAG" "$FILE_TO_CHANGE_1"

update_image "$IMAGE_NAME" "$IMAGE_TAG" "$FILE_TO_CHANGE_2"
log "Finished image updates."

if ! $CHANGES_MADE; then
    log "No changes to commit. Image $IMAGE_NAME:$IMAGE_TAG already present in all locations. Exiting."
fi

COMMIT_MESSAGE="Updated $IMAGE_NAME to $IMAGE_TAG tag in values file"

log "Committing changes"
if ! git add "$FILE_TO_CHANGE_1" "$FILE_TO_CHANGE_2" "$IMAGE_LIST_FILE"; then  
    error_exit "Failed to stage changes"
fi
if ! git commit -m "$COMMIT_MESSAGE"; then
    error_exit "Failed to commit changes"
fi

push_changes() {
    if ! git push origin "$BRANCH_NAME"; then
        log "Push failed. Pulling latest changes, rebasing, and trying again."
        if ! git pull --rebase origin "$BRANCH_NAME"; then
            error_exit "Failed to pull and rebase latest changes"
        fi
        if ! git push origin "$BRANCH_NAME"; then
            error_exit "Failed to push changes after rebase"
        fi
    fi
}

log "Pushing changes"
push_changes

if [ "$RAISE_PR" == "TRUE" ]; then
    PR_TITLE="Chore: Update $IMAGE_NAME"
    PR_BODY="This PR updates the image version for $IMAGE_NAME from $PREVIOUS_TAG to $IMAGE_TAG"

    log "Checking for existing Pull Request"
    EXISTING_PR=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls?head=$REPO_OWNER:$BRANCH_NAME&state=open")


    if [ "$(echo "$EXISTING_PR" | jq '. | length')" -gt 0 ]; then
        PR_NUMBER=$(echo "$EXISTING_PR" | jq -r '.[0].number')
        log "Existing Pull Request found. Updating PR #$PR_NUMBER"
        
        UPDATE_PR_RESPONSE=$(curl -s -X PATCH \
            -H "Authorization: token $GITHUB_API_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER" \
            -d '{
            "title": "'"$PR_TITLE"'",
            "body": "'"$PR_BODY"'"
        }')
        
        PR_URL=$(echo "$UPDATE_PR_RESPONSE" | jq -r '.html_url')
        if [ "$PR_URL" != "null" ]; then
            log "Pull Request updated successfully: $PR_URL"
        else
            error_exit "Failed to update Pull Request. Response: $UPDATE_PR_RESPONSE"
        fi
    else
        log "Creating new Pull Request"
        PR_RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_API_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls" \
            -d '{
            "title": "'"$PR_TITLE"'",
            "body": "'"$PR_BODY"'",
            "head": "'"$BRANCH_NAME"'",
            "base": "main"
        }')

        PR_URL=$(echo "$PR_RESPONSE" | jq -r '.html_url')
        if [ "$PR_URL" != "null" ]; then
            log "Pull Request created successfully: $PR_URL"
        else
            error_exit "Failed to create Pull Request. Response: $PR_RESPONSE"
        fi
    fi
else
    log "Done and Dusted"
fi
