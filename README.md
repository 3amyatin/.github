# .github

[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/3amyatin/.github)
[![Claude Code](https://img.shields.io/badge/AI-Claude_Code-F97316?logo=anthropic&logoColor=white)](https://claude.ai)

Centralized GitHub workflows, configuration, and repo overview for all `3amyatin` repos.

## Centralized Claude Workflows

Provides reusable GitHub Actions workflows so every repo gets automatic Claude-powered code reviews and interactive `@claude` assistance without duplicating workflow files.

### Architecture

```
.github repo (this repo)
├── .github/workflows/
│   ├── claude-review.yml        # Reusable: auto PR review with inline comments
│   ├── claude-assistant.yml     # Reusable: @claude interactive
│   └── claude-issue-triage.yml  # Reusable: auto issue triage
├── caller-workflow.yml        # Template pushed to each repo
└── scripts/
    └── deploy-claude.fish     # Deploys to all repos
```

Each repo receives a thin caller workflow (`.github/workflows/claude.yml`) that delegates to the reusable workflows here. Updates to review logic only need to happen in this repo.

### Features

- Automatic code review on every non-draft PR (opened, synchronized, reopened)
  - Inline comments on specific lines with `suggestion` blocks
  - Context7 MCP integration for up-to-date library docs lookup
  - Summary review comment with overall assessment
- Interactive `@claude` mentions in PR comments, review comments, and issues
- Issue triage with auto-categorization
- Issue assignment/labeling triggers

### Setup

Deploy to all repos:

```fish
./scripts/deploy-claude.fish
```

Deploy to specific repos:

```fish
./scripts/deploy-claude.fish rules max claude
```

Dry run:

```fish
DRY_RUN=1 ./scripts/deploy-claude.fish
```

### Authentication

Uses `CLAUDE_CODE_OAUTH_TOKEN` (OAuth token from Claude subscription). Set per-repo since personal GitHub accounts don't support account-level secrets. The deploy script handles this automatically.

### Updating Workflows

Edit the reusable workflows in `.github/workflows/` and push to `main`. All repos inherit changes immediately since they reference `@main`.

