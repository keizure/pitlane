---
name: release-tag
description: "Intelligent semantic versioning and git tag creation with automatic version bump detection. Analyzes git commits and diffs to generate major.minor.patch version numbers and comprehensive tag descriptions. Use when: (1) Creating release tags, (2) Publishing new versions, (3) Automating version management, (4) Generating release notes. Triggers: 'release tag', 'create tag', 'release version', '打tag', '发布版本', 'create release', 'bump version'. When commits lack clear keywords, outputs diff for Claude to analyze and decide version type."
---

# Semantic Release

Automated semantic version analysis and git tag creation based on commit history and code changes.

## Overview

This skill analyzes git commits using Conventional Commits patterns and intelligently determines whether to bump the MAJOR, MINOR, or PATCH version. It generates comprehensive tag descriptions and ensures proper semantic versioning.

## Quick Start

### Basic Usage

```bash
# Two-phase workflow (recommended for Claude Code)

# Phase 1: Generate release notes template
python skills/release-tag/scripts/analyze_version.py

# This creates ~/.cache/release-tag/v{version}.md with:
# - All commits categorized by type
# - Code change statistics
# - Full diff content
# - Instructions and example format

# Phase 2: Create tag with edited release notes
# (After Claude edits the template)
python skills/release-tag/scripts/analyze_version.py --message-file ~/.cache/release-tag/v{version}.md

# Quick options
# Preview mode (no tag creation)
python skills/release-tag/scripts/analyze_version.py --dry-run

# Override version type if auto-detection is wrong
python skills/release-tag/scripts/analyze_version.py --version-type minor

# Create and push in one go (Phase 2)
python skills/release-tag/scripts/analyze_version.py --message-file ~/.cache/release-tag/v{version}.md --push
```

**Workflow:** Two-phase execution ensures high-quality release notes. Phase 1 generates a template with all context (commits, diff, stats). Claude then edits this template to write a synthesized summary. Phase 2 reads the edited content and creates the tag.

### Common Options

```bash
# Specify branch (default: master)
python skills/release-tag/scripts/analyze_version.py --branch main

# Skip branch update (if already up to date)
python skills/release-tag/scripts/analyze_version.py --no-update

# Preview mode with different branch
python skills/release-tag/scripts/analyze_version.py --branch develop --dry-run
```

## How It Works

### 1. Update Branch

Updates the main branch to ensure analysis is based on latest code:
```bash
git checkout <branch>
git pull origin <branch>
```

### 2. Analyze Commits and Generate Version

**Step 1: Keyword Analysis**

Parses commits since last tag using Conventional Commits patterns:

| Pattern | Version Bump | Example |
|---------|--------------|---------|
| `BREAKING CHANGE:` or `feat!:` | **MAJOR** | `v1.2.3 → v2.0.0` |
| `feat:` or `feature:` | **MINOR** | `v1.2.3 → v1.3.0` |
| `fix:` or `bugfix:` | **PATCH** | `v1.2.3 → v1.2.4` |

**Step 2: Version Decision**

- If keywords found: Use appropriate version bump
- If uncertain: Use conservative PATCH strategy, allow override with `--version-type`

Calculates new version based on commit analysis:

```
Current: v1.5.3

Commits:
- feat: Add OAuth support
- fix: Handle edge case
- docs: Update README

Analysis: Has 'feat' → MINOR bump
Result: v1.6.0
```

See [conventional-commits.md](references/conventional-commits.md) for detailed commit format guide.

### 3. Generate Release Notes Template

**Phase 1 - Template Generation:**

Script creates a comprehensive template at `~/.cache/release-tag/v{version}.md` containing:

1. **Version Information**
   - Version number and total commit count
   - Breakdown by type (breaking/features/fixes/others)

2. **Categorized Commits**
   - Breaking changes
   - New features
   - Bug fixes
   - Other changes

3. **Code Statistics**
   - File change summary (`git diff --stat`)
   - Full diff content for analysis

4. **Instructions & Example**
   - Format requirements
   - Example of high-quality release notes
   - Clear marker where Claude should write

Example template structure:
```markdown
# Release Notes for v1.6.0

## 版本信息
- 版本号: v1.6.0
- 总提交数: 8

## Commit Messages
### 新功能
- feat: Add OAuth support
- feat: Add custom themes

### 修复
- fix: Handle edge case

## 代码变更统计
[git diff stats]

## 详细 Diff
[full diff content]

---
# 👇 在此处编写最终的 Release Notes
[Claude writes here]
```

### 4. Claude Edits Template

Claude (or user) reviews the template and writes a synthesized summary that:
- Focuses on user-visible features and improvements
- Groups related changes meaningfully
- Explains the "why" and impact, not just "what"
- Uses clear, professional language
- Follows the project's release note style

### 5. Create Tag with Quality Release Notes

**Phase 2 - Tag Creation:**

Script reads the edited template and creates an annotated git tag:

```bash
python skills/release-tag/scripts/analyze_version.py \
  --message-file ~/.cache/release-tag/v1.6.0.md
```

The tag description now contains:
- Concise feature summary
- Impact and value explanation
- Technical highlights
- Usage examples (if relevant)

Instead of just:

```markdown
- feat: Add OAuth support
- fix: Handle edge case
```

You get:

```markdown
Release v1.6.0

## ✨ 主要更新

### 认证系统增强
本次更新引入 OAuth 2.0 支持，允许用户使用第三方账号登录，简化认证流程并提升安全性。

**核心特性：**
- 支持 Google 和 GitHub OAuth 提供商
- 自动用户信息同步
- 改进的错误处理和边缘情况处理

### 技术改进
- 修复了高并发场景下的边缘情况问题
- 优化了会话管理性能

## 🚀 使用方式
[Usage examples if relevant]
```

This two-phase workflow ensures every release has clear, valuable documentation.

## Version Decision Logic

```
┌──────────────────────────┐
│ Analyze commit messages  │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ BREAKING CHANGE found?   │
│ (feat!, fix!, or footer) │
└────────────┬─────────────┘
             │
      Yes ───┴─── No
       │           │
       ▼           ▼
  ┌────────┐ ┌────────────┐
  │ MAJOR  │ │ feat: ?    │
  └────────┘ └──────┬─────┘
                    │
             Yes ───┴─── No
              │           │
              ▼           ▼
         ┌────────┐  ┌────────┐
         │ MINOR  │  │ PATCH  │
         └────────┘  └────────┘
```

**Mixed commits:** Highest level wins (BREAKING > feat > fix)

## Workflow Patterns

### Pattern 1: Feature Release (Two-Phase)

```bash
# Multiple features developed, ready to release v1.3.0

# Phase 1: Generate template
python skills/release-tag/scripts/analyze_version.py

# Claude edits ~/.cache/release-tag/v1.3.0.md with quality summary

# Phase 2: Create and push tag
python skills/release-tag/scripts/analyze_version.py \
  --message-file ~/.cache/release-tag/v1.3.0.md --push
```

### Pattern 2: Preview Before Creating

```bash
# Check what version will be created
python skills/release-tag/scripts/analyze_version.py --dry-run

# If satisfied, generate template
python skills/release-tag/scripts/analyze_version.py

# Edit and create
python skills/release-tag/scripts/analyze_version.py \
  --message-file ~/.cache/release-tag/v{version}.md
```

### Pattern 3: Quick Workflow (Skip Update)

```bash
# If already on latest commit

# Phase 1
python skills/release-tag/scripts/analyze_version.py --no-update

# Phase 2
python skills/release-tag/scripts/analyze_version.py \
  --message-file ~/.cache/release-tag/v{version}.md --no-update --push
```

## Best Practices

### ✅ Do

1. **Use Conventional Commits consistently**
   - Makes version detection automatic and reliable
   - See [references/conventional-commits.md](references/conventional-commits.md)

2. **Write quality release notes**
   - Synthesize changes into meaningful features
   - Explain user impact and value
   - Use clear, professional language
   - Follow the example format in templates

3. **Group related changes**
   - Batch fixes into one release
   - Combine features for minor releases

4. **Use descriptive commit messages**
   - Better commit messages = easier to write release notes
   - Include context and impact

### ❌ Don't

1. **Just copy commit messages**
   - Release notes should summarize and synthesize
   - Explain "why" and "what value", not just "what changed"

2. **Skip the template editing step**
   - Quality release notes are essential for users
   - Take time to write clear summaries

3. **Create tags for every tiny change**
   - Wait for meaningful batches
   - Reduces noise in release history

4. **Mix breaking changes with features unnecessarily**
   - Plan major releases separately when possible
   - Reduces upgrade disruption

## Reference Documentation

For detailed information:

- **Commit Format**: See [conventional-commits.md](references/conventional-commits.md) for complete Conventional Commits specification
- **Version Strategy**: See [version-strategy.md](references/version-strategy.md) for semantic versioning rules and decision examples

## Examples

### Example 1: Minor Version Release

```bash
$ python skills/release-tag/scripts/analyze_version.py --dry-run

🚀 语义化版本分析器
============================================================

📥 更新主干分支 (master)...
✓ 分支已更新

🔍 获取版本信息...
   当前版本: v1.2.5

📝 分析提交历史...
   找到 8 个提交

   📊 提交分析:
      破坏性变更: 0
      新功能: 3
      修复: 2
      其他: 3

   📈 版本升级类型: minor
   📦 新版本号: v1.3.0

============================================================
📋 标签描述:
============================================================
Release v1.3.0

## ✨ Features
- Add user export feature
- Support custom themes
- Implement auto-save

## 🐛 Bug Fixes
- Fix login redirect issue
- Resolve memory leak in background task
============================================================

🔍 预览模式 - 未创建标签
```

### Example 2: Major Version (Breaking Change)

```bash
$ python skills/release-tag/scripts/analyze_version.py

...

   📊 提交分析:
      破坏性变更: 1
      新功能: 2
      修复: 1
      其他: 0

   📈 版本升级类型: major
   📦 新版本号: v2.0.0

============================================================
📋 标签描述:
============================================================
Release v2.0.0

## ⚠️ BREAKING CHANGES
- feat!: Redesign API authentication system

## ✨ Features
- Add new REST endpoints
- Support batch operations

## 🐛 Bug Fixes
- Fix timeout handling
============================================================

❓ 确认创建此标签? (y/N): y

🏷️  创建标签 v2.0.0...
✓ 标签已创建: v2.0.0

✅ 完成!
```

## Troubleshooting

### No commits found

```
❌ 没有新的提交，无需创建新版本
```

**Solution:** Check if you have uncommitted changes or if you're on the wrong branch.

### Cannot get current branch

**Solution:** Ensure you're in a git repository with at least one commit.

### Tag already exists

Git will prevent creating duplicate tags. Delete the old tag first:
```bash
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3  # Delete remote
```

## Integration

### CI/CD Pipeline

```yaml
# .github/workflows/release.yml
- name: Create Release Tag
  run: |
    python skills/release-tag/scripts/analyze_version.py --dry-run
    # Manual approval step
    python skills/release-tag/scripts/analyze_version.py --push --no-update
```

### Pre-release Hook

Add to `.git/hooks/pre-push`:
```bash
#!/bin/bash
python skills/release-tag/scripts/analyze_version.py --dry-run
```
