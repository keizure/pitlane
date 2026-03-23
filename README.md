# pitlane
A collection of practical skills for daily development workflow - semantic versioning, work logging, and productivity automation.

## Quick Start
Install any skill with:

```bash
npx skills add keizure/pitlane --skill <skill-name>

# Examples
npx skills add keizure/pitlane --skill release-tag
npx skills add keizure/pitlane --skill personal-plan
```

Then invoke in your agent terminal:

```bash
/release-tag     # Create semantic version tags
/personal-plan   # Capture daily work and ideas
```

## Available Skills

### [`release-tag`](skills/release-tag/SKILL.md)
Intelligent semantic versioning and git tag creation with automatic version bump detection.

**Usage:**
```bash
# Use in Claude Code by typing:
/release-tag

# Or mention it in conversation:
"Please help me create a release tag"
```

### [`personal-plan`](skills/personal-plan/SKILL.md)
Personal information capture and daily planning system based on .plan file format.

**Usage:**
```bash
# Use in Claude Code by typing:
/personal-plan

# Or mention it in conversation:
# Capture (记录)
"Log this: completed the translation system today"
"记下来：今天完成了翻译系统"

# Review (回顾)
"What did I do today"
"今天做了什么"

# Plan (计划)
"Plan tomorrow: review the translation agent code"
"明天做什么：review 翻译 agent 代码"

# Sync (同步)
"Sync plan"
"同步计划"
```

**Features:**
- Simple .plan file format (inspired by [Matteo Landi's .plan revival](https://matteolandi.net/plan-files.html))
- Daily work logging with minimal syntax
- Quick idea capture without context switching
- Project tagging and progress tracking
- Review and planning helpers

## License

MIT
