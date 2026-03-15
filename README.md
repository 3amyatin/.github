# .github

Centralized GitHub workflows and configuration for all `3amyatin` repos.

## What This Does

Provides reusable GitHub Actions workflows so every repo gets automatic Claude-powered code reviews and interactive `@claude` assistance without duplicating workflow files.

## Architecture

```
.github repo (this repo)
├── .github/workflows/
│   ├── claude-review.yml      # Reusable: auto PR review
│   └── claude-assistant.yml   # Reusable: @claude interactive
├── caller-workflow.yml        # Template pushed to each repo
└── scripts/
    └── deploy-claude.fish     # Deploys to all repos
```

Each repo receives a thin caller workflow (`.github/workflows/claude.yml`) that delegates to the reusable workflows here. Updates to review logic only need to happen in this repo.

## Features

- Automatic code review on every PR (opened, synchronized, reopened)
- Interactive `@claude` mentions in PR comments, review comments, and issues
- Issue assignment/labeling triggers

## Setup

### Deploy to all repos

```fish
./scripts/deploy-claude.fish
```

This sets the `CLAUDE_CODE_OAUTH_TOKEN` secret and pushes the caller workflow to every non-archived, non-fork repo.

### Deploy to specific repos

```fish
./scripts/deploy-claude.fish rules max claude
```

### Dry run

```fish
DRY_RUN=1 ./scripts/deploy-claude.fish
```

### New repo onboarding

Run the deploy script with the repo name:

```fish
./scripts/deploy-claude.fish my-new-repo
```

## Authentication

Uses `CLAUDE_CODE_OAUTH_TOKEN` (OAuth token from Claude subscription). Set per-repo since personal GitHub accounts don't support account-level secrets. The deploy script handles this automatically.

## Updating Workflows

Edit the reusable workflows in `.github/workflows/` and push to `main`. All repos inherit changes immediately since they reference `@main`.
