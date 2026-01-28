---
name: release-tag
description: "Intelligent semantic versioning and git tag creation with automatic version bump detection. Use when: (1) Creating release tags, (2) Publishing new versions, (3) Automating version management, (4) Generating release notes. Triggers: 'release tag', 'create tag', 'release version', '打tag', '发布版本', 'create release', 'bump version'."
---

# Release Tag (Prompt-Driven Workflow)

This skill creates an **annotated git tag** with **semantic version bump** and **high-quality release notes**.
It uses git commands + structured summarization.

## Non-Negotiable Rules (Safety)
1. **Never force-push tags.** Do not use `--force` or `--force-with-lease` for tags.
2. **Do not create tags on a dirty working tree.** If `git status` is not clean, stop and ask the user.
3. **Always preview first.** Produce the proposed version + release notes before creating the tag.
4. **Never invent changes.** Only describe what is supported by commits/diff.
5. **If uncertain, ask.** When version bump is ambiguous, default to PATCH and ask user to confirm.

## Inputs You Must Confirm (Ask user if missing)
- Target branch (default: `master`)
- Whether to push tag automatically (default: NO)
- Whether this is a monorepo with multiple packages (default: NO)
- First release behavior: if no existing tags, start from `v0.1.0` unless user specifies otherwise.

---

## When to consult reference docs (optional)
Only open [conventional-commits.md](references/conventional-commits.md) or [version-strategy.md](references/version-strategy.md) when:
- Commit messages are inconsistent / not following Conventional Commits and bump type is disputed
- Repository is in `0.x.x` stage and the bump rule needs clarification
- User asks “why is this MAJOR/MINOR/PATCH?” and you need to quote a source

Otherwise, use the rules embedded in this skill.

---

## Workflow Overview (2-Phase)
### Phase 1 — Analyze & Draft (no tag creation)
Goal: Determine next version (MAJOR/MINOR/PATCH) and draft release notes.

### Phase 2 — Create & Push (tag creation)
Goal: Create annotated tag with final notes and optionally push it.

---

## Phase 0 — Preconditions (must run)
Run these commands and stop if any fails:

```bash
git status
git fetch --tags origin
git checkout <branch>
git pull --ff-only origin <branch>
```

**Stop conditions**
- If `git status` shows uncommitted changes → ask user to commit/stash first.
- If `git pull --ff-only` fails → ask user to resolve divergence (no auto-merge in this skill).

---

## Phase 1 — Analyze & Draft (NO TAG CREATED)

### Step 1 — Identify last tag and commit range
```bash
git describe --tags --abbrev=0
# if none, treat as first release: range = entire history
```

Set range:
- If last tag exists: `<LAST_TAG>..HEAD`
- Else: `HEAD` (first release)

### Step 2 — Collect commits (authoritative source for semver)
```bash
git log <RANGE> --no-merges --pretty=format:"%H%n%s%n%b%n----END----"
```

### Step 3 — Collect diff stats + diff (context for release notes)
```bash
git diff <RANGE> --stat
git diff <RANGE> --unified=3
```

> If diff is huge: summarize by file list + top changed files, and only include partial diff in prompt.
> Do NOT paste megabytes of diff.

### Step 4 — Decide bump type (Conventional Commits rules)
Use these rules:

- **MAJOR** if any commit contains:
  - `BREAKING CHANGE:` in body/footer, OR
  - `feat!:` / `fix!:` (exclamation mark), OR
  - any `!:` after type (e.g. `refactor!:`)
- **MINOR** if any commit type is `feat:` (or `feature:`)
- **PATCH** if commits are only `fix:` / `perf:` / `refactor:` / `docs:` / `chore:` / `test:` / `ci:` etc.
- If ambiguous or non-standard → default PATCH and ask user.

See [conventional-commits.md](references/conventional-commits.md) for detailed commit format guide.

### Step 5 — Compute next version
You MUST ask/confirm current version base:
- If tags exist: use last tag version as base (e.g. `v0.2.0`)
- If no tags: start at `v0.1.0` unless user says otherwise

Then bump:
- MAJOR: `X+1.0.0`
- MINOR: `X.Y+1.0`
- PATCH: `X.Y.Z+1`

See [version-strategy.md](references/version-strategy.md) for semantic versioning rules and decision examples

### Step 6 — Draft Release Notes (preview)
Write a markdown draft using this strict structure:

```md
Release {NEW_VERSION}

## Overview
- <1-2 sentences: what changed and why it matters>

## Highlights
- <2-6 bullets: user-visible changes, grouped>

## Upgrade / Behavior Notes
- <only if needed: breaking changes, migration steps, defaults changed>

## Quick Start (optional)
- <only if this release introduces new command/skill/config>
```

**Constraints**
- Focus on user-visible behavior, not raw commit list.
- No subjective praise.
- If there is risk (tag push, branch requirements), mention it.

At the end of Phase 1, present:
- Proposed `NEW_VERSION`
- Proposed release notes draft
- Ask: "Proceed to create tag? Push to origin?"

---

## Phase 2 — Create & Push Tag (TAG CREATED HERE)

### Step 1 — Create annotated tag
Use one of the following methods:

#### Method A (editor)
```bash
git tag -a <NEW_VERSION>
# paste the release notes, save and exit
```

#### Method B (heredoc; recommended for automation)
```bash
git tag -a <NEW_VERSION> -F - <<'EOF'
<PASTE FINAL RELEASE NOTES MARKDOWN HERE>
EOF
```

### Step 2 — Verify tag
```bash
git show <NEW_VERSION>
```

### Step 3 — Push (optional, ask first)
```bash
git push origin <NEW_VERSION>
```

---

## Common Anti-Patterns (Do NOT do)
- ❌ Creating tag without fetching latest tags / pulling latest branch
- ❌ Creating tag on a dirty working tree
- ❌ Writing release notes by copying commit subjects verbatim
- ❌ Force pushing tags
- ❌ Describing features not present in commits/diff

---

## Output Checklist (what you must show the user)
Before creating tag:
- [ ] last tag (or first release)
- [ ] commit count in range
- [ ] proposed bump type + reason (which commit triggered it)
- [ ] proposed new version
- [ ] release notes preview
- [ ] confirm whether to push tag

After creating tag:
- [ ] `git show <tag>`
- [ ] (if pushed) `git ls-remote --tags origin | grep <tag>`
