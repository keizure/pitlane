# pitlane
A collection of practical Claude Code skills for daily development workflow - semantic versioning, work logging, and productivity automation.

## Installation

### Install as Claude Code Plugin

Install the entire plugin to get all skills:

```bash
# Add this repo as a marketplace
/plugin marketplace add keizure/pitlane

# Install the plugin
/plugin install pit@pitlane
```

Once installed, all skills will be available in your Claude Code sessions.

### Install Individual Skills

Install only the skills you need:

```bash
# General format
npx skills add keizure/pitlane --skill <skill-name>

# Examples
npx skills add keizure/pitlane --skill release-tag
npx skills add keizure/pitlane --skill personal-plan
```

## Available Skills

### `release-tag`
Intelligent semantic versioning and git tag creation with automatic version bump detection.

**Usage:**
```bash
# Use in Claude Code by typing:
/release-tag

# Or mention it in conversation:
"Please help me create a release tag"
```

### `personal-plan`
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

See [skills/personal-plan/SKILL.md](skills/personal-plan/SKILL.md) for detailed documentation.

## Development

### Testing

This project includes comprehensive tests to ensure quality.

```bash
# Run all tests
cd tests
./run_tests.sh

# Run integration tests
./tests/integration/test_release_tag.sh

# Set up manual test fixtures
cd tests/fixtures/basic
./setup.sh
# Now test the skill in Claude Code
```

See [tests/README.md](tests/README.md) for detailed testing documentation and [VALIDATION.md](VALIDATION.md) for quick validation guide.

### Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on:
- Development setup
- Making changes
- Testing requirements
- Pull request process

---

## License

MIT - Use freely, modify as needed, contribute back if you can.

---