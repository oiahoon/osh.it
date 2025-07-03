#!/usr/bin/env zsh
# ACW (Advanced Code Workflow) Plugin for OSH
# Git workflow automation with JIRA integration

# Load vintage design system
if [[ -z "${OSH_VINTAGE_LOADED:-}" ]] && [[ -f "${OSH}/lib/vintage.zsh" ]]; then
  source "${OSH}/lib/vintage.zsh"
fi

# Load common libraries for git validation
if [[ -z "${OSH_COMMON_LOADED:-}" ]] && [[ -f "${OSH}/lib/common.zsh" ]]; then
  source "${OSH}/lib/common.zsh"
fi

# Set author name for branch creation
AUTHOR="${USER}"
if [[ -n "${GITUSER:-}" ]]; then
  AUTHOR="${GITUSER}"
fi


# Create git branch for ACW workflow
# Usage: acw [base-branch]
# Example: acw develop
acw() {
  local branchBase="master"
  local jiraNumber
  local issueKey
  local issueTitle
  local dt
  local branchName
  
  # Validate we're in a git repository
  if ! osh_validate_git_repo; then
    return 1
  fi
  
  # Parse base branch parameter
  if [[ -n "${1:-}" ]]; then
    branchBase="$(osh_string_trim "${1}")"
  fi
  
  osh_color_info "Create new branch for ACW based on ${branchBase}"
  
  # Get JIRA ticket number
  printf "${GREEN}Please enter the JIRA ticket's number (integer): ${YELLOW}"
  read -r jiraNumber
  
  if [[ -z "${jiraNumber}" ]]; then
    osh_color_error "JIRA number is required!"
    return 1
  fi
  
  # Validate JIRA number is numeric
  if ! [[ "${jiraNumber}" =~ ^[0-9]+$ ]]; then
    osh_color_error "JIRA number must be numeric!"
    return 1
  fi

  # Get issue information
  printf "${GREEN}Getting ticket's info...${YELLOW}"
  issueKey="ACW-${jiraNumber}"
  
  if ! issueTitle=$(issueTitle "${issueKey}"); then
    osh_color_error "Failed to get issue title for ${issueKey}"
    return 1
  fi
  
  printf " %s${NOCOLOR}\n" "${issueTitle}"
  
  # Generate branch name
  dt=$(osh_date_short)
  branchName="ACW-${jiraNumber}-${AUTHOR}-${dt}-$(osh_string_slugify "${issueTitle}")"
  
  osh_color_info "Creating branch: ${branchName}"

  # Create branch
  if ! git checkout "${branchBase}"; then
    osh_color_error "Failed to checkout base branch: ${branchBase}"
    return 1
  fi
  
  if ! git pull origin "${branchBase}"; then
    osh_color_error "Failed to pull latest changes from ${branchBase}"
    return 1
  fi
  
  if ! git checkout -b "${branchName}"; then
    osh_color_error "Failed to create branch: ${branchName}"
    return 1
  fi
  
  osh_color_success "Successfully created branch: ${branchName}"
}

# Quickly switch branch by keyword
# Usage: ggco <keyword>
# Example: ggco 123 (switches to branch containing "123")
ggco() {
  local keyword="${1:-}"
  local result
  local branch_name
  
  # Validate we're in a git repository
  if ! osh_validate_git_repo; then
    return 1
  fi
  
  if [[ -z "${keyword}" ]]; then
    osh_color_error "Usage: ggco <keyword>"
    osh_color_info "Example: ggco 123 (keyword can be JIRA number or branch name part)"
    return 1
  fi
  
  # Search for matching branch
  result=$(git branch -a | grep -i "${keyword}" | head -n1)
  
  if [[ -z "${result}" ]]; then
    osh_color_warning "No branch found matching keyword: ${keyword}"
    return 1
  fi
  
  # Extract branch name (remove spaces and remote prefix)
  branch_name="$(osh_string_trim "${result}")"
  branch_name="${branch_name#remotes/origin/}"  # Remove remote prefix
  
  osh_color_info "Switching to branch: ${branch_name}"
  
  if ! git checkout "${branch_name}"; then
    osh_color_error "Failed to checkout branch: ${branch_name}"
    return 1
  fi
}


# Create general purpose git branch
# Usage: newb [base-branch]
# Example: newb develop
newb() {
  local branchBase="master"
  local branchDesc
  local dt
  local branchName
  
  # Validate we're in a git repository
  if ! osh_validate_git_repo; then
    return 1
  fi
  
  # Parse base branch parameter
  if [[ -n "${1:-}" ]]; then
    branchBase="$(osh_string_trim "${1}")"
  fi
  
  osh_color_info "Create new branch based on ${branchBase}"
  
  # Get branch description
  printf "${GREEN}Please enter the brief description (required): ${YELLOW}"
  read -r branchDesc
  
  if [[ -z "${branchDesc}" ]]; then
    osh_color_error "Description is required!"
    return 1
  fi

  # Generate branch name
  dt=$(osh_date_short)
  branchName="${AUTHOR}/${dt}-$(osh_string_slugify "${branchDesc}")"

  osh_color_info "Creating branch: ${branchName}"

  # Create branch
  if ! git checkout "${branchBase}"; then
    osh_color_error "Failed to checkout base branch: ${branchBase}"
    return 1
  fi
  
  if ! git pull origin "${branchBase}"; then
    osh_color_error "Failed to pull latest changes from ${branchBase}"
    return 1
  fi
  
  if ! git checkout -b "${branchName}"; then
    osh_color_error "Failed to create branch: ${branchName}"
    return 1
  fi
  
  osh_color_success "Successfully created branch: ${branchName}"
}


# Get JIRA issue title by issue key
# Usage: issueTitle <issue-key>
# Example: issueTitle ACW-123
issueTitle() {
  local issueKey="${1:-}"
  local issueUrl
  local issueTitle
  
  if [[ -z "${issueKey}" ]]; then
    osh_color_error "Please provide JIRA issue key"
    return 1
  fi
  
  # Validate required environment variables
  if ! osh_validate_env_var "JIRAURL" "JIRA instance URL"; then
    return 1
  fi
  
  if ! osh_validate_env_var "JIRATOKEN" "JIRA authentication token (base64 encoded username:password)"; then
    return 1
  fi
  
  # Validate required commands
  if ! osh_validate_command "curl"; then
    return 1
  fi
  
  if ! osh_validate_command "jq"; then
    return 1
  fi
  
  # Remove spaces from issue key
  issueKey="$(osh_string_trim "${issueKey}")"
  issueUrl="${JIRAURL}/rest/api/2/issue/${issueKey}"
  
  # Fetch issue title
  issueTitle=$(curl -s -H "Authorization: Basic ${JIRATOKEN}" \
                   -X GET \
                   -H "Content-Type: application/json" \
                   "${issueUrl}" | jq -r ".fields.summary" 2>/dev/null)
  
  if [[ -z "${issueTitle}" || "${issueTitle}" == "null" ]]; then
    osh_color_error "Failed to get issue title for ${issueKey}"
    return 1
  fi
  
  # Clean up title (remove quotes and special characters)
  issueTitle="${issueTitle//[\-\'\"]/}"
  
  printf "%s" "${issueTitle}"
}
