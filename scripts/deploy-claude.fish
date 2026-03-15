#!/usr/bin/env fish
#
# Deploy Claude workflows and secrets to all 3amyatin GitHub repos.
#
# Usage:
#   ./scripts/deploy-claude.fish                    # deploy to all repos
#   ./scripts/deploy-claude.fish rules max claude   # deploy to specific repos
#   DRY_RUN=1 ./scripts/deploy-claude.fish          # preview without changes

set -l script_dir (dirname (status filename))
set -l repo_root (dirname $script_dir)
set -l caller_workflow "$repo_root/caller-workflow.yml"
set -l owner "3amyatin"

# Colors
set -l green (set_color green)
set -l red (set_color red)
set -l yellow (set_color yellow)
set -l reset (set_color normal)

function log_ok
    echo "$green✓$reset $argv"
end

function log_skip
    echo "$yellow→$reset $argv"
end

function log_err
    echo "$red✗$reset $argv"
end

# Validate prerequisites
if not command -q gh
    log_err "gh CLI not found. Install: brew install gh"
    exit 1
end

if not test -f $caller_workflow
    log_err "Caller workflow not found: $caller_workflow"
    exit 1
end

# Get token
if not set -q CLAUDE_CODE_OAUTH_TOKEN
    echo "Enter CLAUDE_CODE_OAUTH_TOKEN (paste and press Enter):"
    read -s -l token
    if test -z "$token"
        log_err "Token cannot be empty"
        exit 1
    end
    set -g CLAUDE_CODE_OAUTH_TOKEN $token
end

# Determine target repos
if test (count $argv) -gt 0
    set repos $argv
else
    set repos (gh repo list $owner --limit 100 --json name,isArchived,isFork \
        --jq '.[] | select(.isArchived == false and .isFork == false) | .name')
end

# Skip the .github repo itself
set -l filtered_repos
for repo in $repos
    if test "$repo" != ".github"
        set -a filtered_repos $repo
    end
end
set repos $filtered_repos

echo "Deploying Claude workflows to "(count $repos)" repos..."
echo ""

set -l ok_count 0
set -l skip_count 0
set -l err_count 0

for repo in $repos
    set -l full_repo "$owner/$repo"

    # Check if repo exists and is accessible
    if not gh repo view $full_repo --json name >/dev/null 2>&1
        log_err "$repo — not accessible"
        set err_count (math $err_count + 1)
        continue
    end

    if set -q DRY_RUN
        log_skip "$repo — dry run, would deploy"
        set skip_count (math $skip_count + 1)
        continue
    end

    # Set secret
    echo -n $CLAUDE_CODE_OAUTH_TOKEN | gh secret set CLAUDE_CODE_OAUTH_TOKEN \
        --repo $full_repo 2>/dev/null
    if test $status -ne 0
        log_err "$repo — failed to set secret"
        set err_count (math $err_count + 1)
        continue
    end

    # Check default branch
    set -l default_branch (gh repo view $full_repo --json defaultBranchRef \
        --jq '.defaultBranchRef.name' 2>/dev/null)
    if test -z "$default_branch"
        set default_branch "main"
    end

    # Check if workflow already exists
    set -l existing (gh api "repos/$full_repo/contents/.github/workflows/claude.yml?ref=$default_branch" \
        --jq '.sha' 2>/dev/null)

    # Deploy caller workflow via GitHub API
    set -l content (base64 < $caller_workflow)
    set -l message "ci: add centralized Claude review workflow"

    if test -n "$existing"
        # Update existing file
        gh api "repos/$full_repo/contents/.github/workflows/claude.yml" \
            --method PUT \
            --field message="$message" \
            --field content="$content" \
            --field branch="$default_branch" \
            --field sha="$existing" \
            >/dev/null 2>&1
    else
        # Create new file
        gh api "repos/$full_repo/contents/.github/workflows/claude.yml" \
            --method PUT \
            --field message="$message" \
            --field content="$content" \
            --field branch="$default_branch" \
            >/dev/null 2>&1
    end

    if test $status -eq 0
        log_ok "$repo — deployed"
        set ok_count (math $ok_count + 1)
    else
        log_err "$repo — failed to push workflow"
        set err_count (math $err_count + 1)
    end
end

echo ""
echo "Done: $green$ok_count deployed$reset, $yellow$skip_count skipped$reset, $red$err_count errors$reset"
