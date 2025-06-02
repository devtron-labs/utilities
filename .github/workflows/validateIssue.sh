#!/bin/bash

# Print base and head repository information
echo "base or target repo : $BASE_REPO"
echo "head or source repo : $HEAD_REPO"

# Determine if the PR is from a forked repository
if [[ $HEAD_REPO == $BASE_REPO ]]; then
    export forked=false
else
    export forked=true
fi

# Skip validation for documentation or chore PRs
if [[ "$TITLE" =~ ^(doc:|docs:|chore:|misc:|Release:|release:|Sync:|sync:) ]]; then
    echo "Skipping validation for docs/chore PR."
    echo "PR NUMBER-: $PRNUM "
    if [[ "$forked" == "false" ]]; then
        # If not a forked PR, remove 'Issue-verification-failed' and add 'Ready-to-Review' label
        gh pr edit $PRNUM --remove-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --add-label "PR:Ready-to-Review"
    fi
    exit 0
fi

# Define all issue matching patterns
# These patterns cover various ways issues can be linked in a PR body
patterns=(
    "((Fixes|fixes|Resolves|resolves) #[0-9]+)" # e.g., Fixes #123
    "((Fixes|fixes|Resolves|resolves) https://github.com/devtron-labs/(devtron|sprint-tasks|devops-sprint|devtron-enterprise)/issues/[0-9]+)" # e.g., Fixes https://github.com/devtron-labs/devtron/issues/123
    "((Fixes|fixes|Resolves|resolves):? https://github.com/devtron-labs/(devtron|sprint-tasks|devops-sprint|devtron-enterprise)/issues/[0-9]+)" # e.g., Fixes: https://github.com/devtron-labs/devtron/issues/123
    "((Fixes|fixes|Resolves|resolves) devtron-labs/devtron#[0-9]+)" # e.g., Fixes devtron-labs/devtron#123
    "((Fixes|fixes|Resolves|resolves) devtron-labs/sprint-tasks#[0-9]+)"
    "((Fixes|fixes|Resolves|resolves) devtron-labs/devops-sprint#[0-9]+)"
    "(Fixes|fixes|Resolves|resolves):?\\s+\\[#([0-9]+)\\]" # e.g., Fixes [#123]
    "((Fixes|fixes|Resolves|resolves):? #devtron-labs/devops-sprint/issues/[0-9]+)" # e.g., Fixes: #devtron-labs/devops-sprint/issues/123
    "((Fixes|fixes|Resolves|resolves):? #devtron-labs/sprint-tasks/issues/[0-9]+)"
)

# Function to extract all unique issue numbers and their corresponding repositories from PR_BODY
# It iterates through defined patterns and extracts all matches.
# Returns a list of "issue_num,repo" pairs, one per line.
extract_all_issues() {
    local -a found_issues=()
    local default_repo="devtron-labs/devtron" # Default repository if not explicitly mentioned in the link

    # Loop through each defined pattern
    for pattern in "${patterns[@]}"; do
        # Use grep -oE to find all non-overlapping matches for the current pattern in PR_BODY
        matches=$(echo "$PR_BODY" | grep -oE "$pattern")

        # If matches are found for the current pattern
        if [[ -n "$matches" ]]; then
            echo "Matched for pattern: $pattern"
            # Read each match into the 'match' variable
            while IFS= read -r match; do
                # Extract the issue number (sequence of digits) from the matched string
                local current_issue_num=$(echo "$match" | grep -oE "[0-9]+")
                # Extract the repository name (e.g., devtron-labs/devtron) from the matched string
                local current_repo=$(echo "$match" | grep -oE "devtron-labs/[a-zA-Z0-9_-]+")

                # If no specific repository is found in the link, use the default
                if [[ -z "$current_repo" ]]; then
                    current_repo="$default_repo"
                fi

                # If a valid issue number was extracted, add it to the list
                if [[ -n "$current_issue_num" ]]; then
                    found_issues+=("$current_issue_num,$current_repo")
                    echo "Extracted issue: $current_issue_num from repo: $current_repo"
                fi
            done <<< "$matches" # Use a here-string to feed matches into the while loop
        fi
    done
    # Print unique issue-repo pairs, sorted, to avoid duplicate validations
    printf "%s\n" "${found_issues[@]}" | sort -u
}

# Call the function to extract all unique issue-repo pairs and store them in an array
readarray -t all_issues < <(extract_all_issues)

# Check if any issues were found in the PR body
if [[ ${#all_issues[@]} -eq 0 ]]; then
    echo "No valid issue number found in PR body."
    if [[ "$forked" == "false" ]]; then
        # If not a forked PR, add 'Issue-verification-failed' and remove 'Ready-to-Review' label
        gh pr edit $PRNUM --add-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --remove-label "PR:Ready-to-Review"
    fi
    exit 1
fi

# Initialize a flag to track overall validation status and a string to collect failed links
all_issues_valid=true
failed_issue_links=""

# Loop through each unique issue-repo pair found
for issue_repo_pair in "${all_issues[@]}"; do
    # Split the pair into issue_num and repo using comma as delimiter
    IFS=',' read -r issue_num repo <<< "$issue_repo_pair"

    echo "Validating issue number: #$issue_num in repo: $repo"

    # Form the GitHub API URL for the issue
    issue_api_url="https://api.github.com/repos/$repo/issues/$issue_num"
    echo "API URL: $issue_api_url"

    local response=""
    local response_code=""
    local response_body=""

    # Determine if the repository is public or private to apply authentication
    if [[ "$repo" == "devtron-labs/devtron" || "$repo" == "devtron-labs/devtron-services" || "$repo" == "devtron-labs/dashboard" ]]; then
        echo "No extra arguments needed: public repository detected."
        # Use curl to get the response body and HTTP status code
        response=$(curl -s -w "%{http_code}" "$issue_api_url")
    else
        echo "Adding extra arguments for authentication: private repository detected."
        # Use curl with authentication headers for private repositories
        response=$(curl -s -w "%{http_code}" --header "Authorization: Bearer $GH_PR_VALIDATOR_TOKEN" \
            --header "Accept: application/vnd.github+json" "$issue_api_url")
    fi

    # Extract HTTP status code (last line of curl output) and response body
    response_code=$(echo "$response" | tail -n 1)
    response_body=$(echo "$response" | head -n -1)

    echo "Response Code: $response_code"
    # Extract the 'html_url' from the JSON response body using jq
    local html_url=$(echo "$response_body" | jq -r '.html_url')

    # Check if the extracted URL points to a pull request instead of an issue
    if [[ "$html_url" == *"pull"* ]]; then
        echo "The issue URL contains a pull-request link, marking as invalid."
        # Append error message to the failed_issue_links string
        failed_issue_links+="Issue #$issue_num in $repo is linked to a pull request URL, which is invalid.\n"
        all_issues_valid=false # Set overall status to invalid
    elif [[ "$response_code" -eq 200 ]]; then
        # If HTTP status code is 200, the issue is valid
        echo "Issue Number: #$issue_num is valid and exists in Repo: $repo."
    else
        # If issue not found or invalid HTTP status code
        echo "Issue not found. Invalid URL or issue number: #$issue_num in $repo."
        failed_issue_links+="Issue #$issue_num in $repo is not found or invalid (HTTP $response_code).\n"
        all_issues_valid=false # Set overall status to invalid
    fi
done

# Final label application and comments based on the overall validation status
if [[ "$forked" == "false" ]]; then
    # If not a forked PR, modify labels and add comments
    if [[ "$all_issues_valid" == "true" ]]; then
        # All issues are valid, remove 'Issue-verification-failed' and add 'Ready-to-Review'
        gh pr edit $PRNUM --remove-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --add-label "PR:Ready-to-Review"
        echo "All linked issues are valid. PR:Ready-to-Review."
        exit 0
    else
        # Some issues are invalid, add a comment with details and update labels
        gh pr comment $PRNUM --body "Some linked issues are invalid. Please update the issue links:\n$failed_issue_links"
        gh pr edit $PRNUM --add-label "PR:Issue-verification-failed"
        gh pr edit $PRNUM --remove-label "PR:Ready-to-Review"
        echo "Some linked issues are invalid. PR:Issue-verification-failed."
        exit 1
    fi
else
    # For forked PRs, just output the status, do not modify labels
    if [[ "$all_issues_valid" == "true" ]]; then
        echo "All linked issues are valid for forked PR."
        exit 0
    else
        echo "Some linked issues are invalid for forked PR:\n$failed_issue_links"
        exit 1
    fi
fi