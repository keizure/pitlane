# Pitlane (AGENTS.md)

This file is instructions for agentic coding tools operating in this repository.
Keep it factual and repo-specific; prefer commands and conventions that are enforced by CI.

## Repo overview

- This repo is a Claude Code plugin repo: skills live under `skills/` and tests are bash-based under `tests/`.
- There is no application build artifact here; CI focuses on test execution and format validation.

## Commands (source of truth)

### Tests (recommended)

Run everything (matches CI behavior):

```bash
cd tests
./run_tests.sh
```

Run a single suite (smallest practical unit in this repo):

```bash
cd tests
bash skills/release-tag/test_release_tag.sh
```

Notes:

- CI runs `cd tests` then `bash run_tests.sh` (`.github/workflows/test.yml`).
- `README.md` mentions `./tests/integration/test_release_tag.sh`, but the actual suite is
  `tests/skills/release-tag/test_release_tag.sh` (see `tests/README.md`).

### Validation (“lint”-like checks)

CI enforces the following checks in `.github/workflows/test.yml`:

SKILL.md frontmatter sanity (for `skills/release-tag/SKILL.md`):

- file exists
- first line is `---`
- contains `name:`
- contains `description:`

plugin.json must be valid JSON:

```bash
python3 -m json.tool .claude-plugin/plugin.json > /dev/null
```

Optional local copy of the CI SKILL.md checks (mirrors `.github/workflows/test.yml`):

```bash
test -f skills/release-tag/SKILL.md
head -1 skills/release-tag/SKILL.md | grep -q '^---$'
grep -q '^name:' skills/release-tag/SKILL.md
grep -q '^description:' skills/release-tag/SKILL.md
```

### Build

- No canonical build command exists in this repo (no `Makefile`/`Taskfile`/`package.json`/`pyproject.toml`, and CI does not run a build step).

## Prerequisites / environment assumptions

- `bash` for all test scripts (`tests/run_tests.sh`, `tests/skills/release-tag/test_release_tag.sh`).
- `git` is required by tests and fixtures (the suite creates temporary git repos).
- `python3` is required for CI-style JSON validation (`python3 -m json.tool ...`).

## Repository layout conventions

- Skills:
  - `skills/<skill-name>/SKILL.md` (required)
  - `skills/<skill-name>/references/` (optional)
- Commands (docs to invoke skills): `commands/*.md`
- Tests:
  - `tests/run_tests.sh` auto-discovers suites
  - `tests/skills/<skill-name>/test_<skill-name>.sh`
  - `tests/skills/<skill-name>/fixtures/<scenario>/setup.sh`

## Making changes (expected workflow)

- If you change skill behavior or output requirements:
  - update `skills/<skill-name>/SKILL.md`
  - update/add tests under `tests/skills/<skill-name>/`
  - run `cd tests && ./run_tests.sh`
- If you change plugin packaging/versioning:
  - update `.claude-plugin/plugin.json`
  - re-run `python3 -m json.tool .claude-plugin/plugin.json > /dev/null`

Manual fixtures:

- Fixture setup scripts live under `tests/skills/<skill-name>/fixtures/<scenario>/setup.sh`.
- Some fixtures and troubleshooting assume git user identity is configured (see `VALIDATION.md`).

## Code style and conventions

This repo is mostly Markdown + bash. Prefer following existing patterns over introducing new tooling.

### Bash scripts (tests/fixtures)

- Start with `#!/bin/bash`.
- Use `set -e` (existing suites rely on this).
- Use functions + small helpers (`log_info`, `assert_equals`) for readability.
- Always clean up temp directories using `trap cleanup EXIT`.
- Quote variables unless deliberate word-splitting is required.
- Return non-zero on failure; do not swallow errors.

### Test conventions

- Suite files must be named `test_*.sh` to be discovered by `tests/run_tests.sh`.
- Keep tests isolated; do not depend on global state.
- Prefer atomic assertions (one behavior per test) and descriptive test names.

### Markdown / docs

- Keep docs concise and actionable. Prefer concrete commands and file paths.
- When documenting a workflow, align it with what CI runs.
- If docs drift from reality, update docs together with code changes.

### SKILL.md format

- Must start with YAML frontmatter (`---` on the first line) and include at least:
  - `name:`
  - `description:`
- Keep `description` short and include triggers/keywords if relevant.

### Commit messages

- Follow Conventional Commits (`CONTRIBUTING.md` and `skills/release-tag/references/conventional-commits.md`).
- Use imperative, lowercase subjects; avoid trailing periods.
- Use `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `ci:` etc; use `!` or `BREAKING CHANGE:` when applicable.

## What not to do

- Don’t “fix tests” by deleting assertions or weakening validation; adjust behavior + update tests together.
- Don’t introduce new build systems/dependencies unless the repo starts needing them (keep it Markdown + bash).
- Don’t rewrite history or force-push tags; avoid irreversible git operations unless explicitly requested.

## Error handling / safety expectations (for agents)

- Prefer small, focused changes; avoid refactors mixed with fixes.
- Do not invent behavior or claims not supported by code/tests.
- Avoid destructive git operations (force-push, hard reset) unless explicitly requested.
- Do not create tags/releases on a dirty working tree.

## Versioning

- Plugin version is in `.claude-plugin/plugin.json`.
- Release tagging behavior is defined by the `skills/release-tag/SKILL.md` workflow.

## Cursor / Copilot rules

- No `.cursorrules`, `.cursor/rules/`, or `.github/copilot-instructions.md` were found at time of writing.
- If such rules are added later, treat them as authoritative and update this document accordingly.
