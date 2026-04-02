# .github — Centralized Workflows & Repo Overview

This repo contains reusable GitHub Actions workflows shared across all `3amyatin` repos, plus a comprehensive overview of all repositories.

## Structure

- `.github/workflows/claude-review.yml` — reusable workflow for automatic PR review (agent mode)
- `.github/workflows/claude-assistant.yml` — reusable workflow for `@claude` interactive responses (tag mode)
- `caller-workflow.yml` — template deployed to each repo as `.github/workflows/claude.yml`
- `scripts/deploy-claude.fish` — deployment script for secrets and caller workflow
- `README.md` — full repo overview with categories, descriptions, and stats

## How It Works

1. Each repo has a thin caller workflow that delegates to reusable workflows in this repo via `uses: 3amyatin/.github/.github/workflows/<name>.yml@main`
2. Caller uses `secrets: inherit` to pass `CLAUDE_CODE_OAUTH_TOKEN`
3. Review workflow triggers on `pull_request` events
4. Assistant workflow triggers on `issue_comment`, `pull_request_review_comment`, `pull_request_review`, and `issues` events

## Conventions

- Reusable workflows use `workflow_call` trigger
- Caller workflow job names: `review` (PR review) and `assistant` (@claude interactive)
- Secret name: `CLAUDE_CODE_OAUTH_TOKEN` (set per-repo via deploy script)
- Caller workflow filename in target repos: `.github/workflows/claude.yml`
- Commit message for deployment: `ci: add centralized Claude review workflow`
- All non-Claude CI/CD workflows disabled across repos as of 2026-04-02 (deploys are manual)

## Repo Overview

Full categorized repo overview lives in `~/Documents/dev/CLAUDE.md` (local only, not committed to any public repo).
