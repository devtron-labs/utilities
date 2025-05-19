#!/bin/bash

echo "base or target repo : $BASE_REPO"
echo "head or source repo : $HEAD_REPO"

if [[ $HEAD_REPO  == $BASE_REPO ]]; then
    export forked=false
else
    export forked=true
fi

# Skip validation for documentation or chore PRs
if [[ "$TITLE" =~ ^(doc:|docs:|chore:|misc:|Release:|release:|Sync:|sync:) ]]; then
    echo "Skipping validation for docs/chore PR."
    echo "PR NUMBER-: $PRNUM "
    if [[ "$forked" == "false" ]]; then
        gh pr edit $PRNUM --remove-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --add-label "PR:Ready-to-Review"
    fi
    exit 0
fi

# Define all issue matching patterns
patterns=(
    "((Fixes|fixes|Resolves|resolves) #[0-9]+)"
    "((Fixes|fixes|Resolves|resolves) https://github.com/devtron-labs/(devtron|sprint-tasks|devops-sprint|devtron-enterprise)/issues/[0-9]+)"
    "((Fixes|fixes|Resolves|resolves):? https://github.com/devtron-labs/(devtron|sprint-tasks|devops-sprint|devtron-enterprise)/issues/[0-9]+)"
    "((Fixes|fixes|Resolves|resolves) devtron-labs/devtron#[0-9]+)"
    "((Fixes|fixes|Resolves|resolves) devtron-labs/sprint-tasks#[0-9]+)"
    "((Fixes|fixes|Resolves|resolves) devtron-labs/devops-sprint#[0-9]+)"
    "(Fixes|fixes|Resolves|resolves):?\\s+\\[#([0-9]+)\\]"
    "((Fixes|fixes|Resolves|resolves):? #devtron-labs/devops-sprint/issues/[0-9]+)"
    "((Fixes|fixes|Resolves|resolves):? #devtron-labs/sprint-tasks/issues/[0-9]+)"
)

# Extract issue number and repo from PR body
extract_issue_number() {
    local pattern="$1"  # Get the pattern as the first argument to the function

    # Check if PR_BODY matches the provided pattern using Bash's =~ regex operator
    if [[ "$PR_BODY" =~ $pattern ]]; then
        echo "matched for this pattern $pattern"

        issue_num=$(echo "$PR_BODY" | grep -oE "$pattern" | grep -oE "[0-9]+")

        # Extract the repository name (e.g., devtron-labs/devtron) from PR_BODY using grep
        repo=$(echo "$PR_BODY" | grep -oE "devtron-labs/[a-zA-Z0-9_-]+")
        echo "Extracted issue number: $issue_num from repo: $repo"

        return 0  # Return success
    else
        echo "No match for the pattern $pattern"
    fi
    return 1  # Return failure if no match
}

issue_num=""
repo="devtron-labs/devtron"  # Default repo
for pattern in "${patterns[@]}"; do
    echo "Now checking for $pattern"
    extract_issue_number "$pattern" && break
done

if [[ -z "$issue_num" ]]; then
    echo "No valid issue number found."
    if [[ "$forked" == "false" ]]; then
        gh pr edit $PRNUM --add-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --remove-label "PR:Ready-to-Review"
    fi
    exit 1
fi

# Form the issue API URL dynamically
issue_api_url="https://api.github.com/repos/$repo/issues/$issue_num"
echo "API URL: $issue_api_url"

if [[ $repo == "devtron-labs/devtron" || $repo == "devtron-labs/devtron-services" || $repo == "devtron-labs/dashboard" ]]; then
    echo "No extra arguments needed: public repository detected."
    response=$(curl -s -w "%{http_code}" "$issue_api_url")  # Get the response body and status code in one go
else
    echo "Adding extra arguments for authentication: private repository detected."
    response=$(curl -s -w "%{http_code}" --header "Authorization: Bearer ${{ secrets.GH_PR_VALIDATOR_TOKEN }}" \
        --header "Accept: application/vnd.github+json" "$issue_api_url")
fi

# Extract HTTP status code from the response
response_code=$(echo "$response" | tail -n 1)  # Status code is the last line
response_body=$(echo "$response" | head -n -1)  # The body is everything except the last line (status code)

echo "Response Code: $response_code"
html_url=$(echo "$response_body" | jq -r '.html_url')  # Extract html_url from the JSON response

# Check if the html_url contains "pull-request"
if [[ "$html_url" == *"pull"* ]]; then
    echo "The issue URL contains a pull-request link, marking as invalid."
    gh pr comment $PRNUM --body "PR is linked to a pull request URL, which is invalid. Please update the issue link."

    if [[ "$forked" == "false" ]]; then
        # Apply 'Issue-verification-failed' label and remove 'Ready-to-Review' label.
        gh pr edit $PRNUM --add-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --remove-label "PR:Ready-to-Review"
    fi
    exit 1
fi

# If response_code is 200, proceed with validating the issue
if [[ "$response_code" -eq 200 ]]; then
    echo "Issue Number: #$issue_num is valid and exists in Repo: $repo."
    if [[ "$forked" == "false" ]]; then
        gh pr edit $PRNUM --remove-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --add-label "PR:Ready-to-Review"
    fi
    echo "PR:Ready-to-Review, exiting gracefully"
    exit 0
else
    echo "Issue not found. Invalid URL or issue number."
    gh pr comment $PRNUM --body "PR is not linked to a valid issue. Please update the issue link."

    if [[ "$forked" == "false" ]]; then
        # Apply 'Issue-verification-failed' label and remove 'Ready-to-Review' label.
        gh pr edit $PRNUM --add-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --remove-label "PR:Ready-to-Review"
    fi
    exit 1
fi