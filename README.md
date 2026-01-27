# pitlane
Production-ready agents, skills, hooks, commands, rules of intensive daily use building real products.

## Installation

### Install as Plugin (Recommended)

The easiest way to use this repo - install as a Claude Code plugin:


```bash
# Add this repo as a marketplace
/plugin marketplace add keizure/pitlane

# Install the plugin
/plugin install pitlane/pitlane
```

Once installed, the skills will be available in your Claude Code sessions.

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

**Features:**
- Automatic version detection (major/minor/patch)
- Conventional Commits parsing
- Two-phase workflow with quality release notes
- Git tag creation and pushing

See [skills/release-tag/SKILL.md](skills/release-tag/SKILL.md) for detailed documentation.

---

## License

MIT - Use freely, modify as needed, contribute back if you can.

---