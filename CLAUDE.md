# Claude Code Instructions for pitlane Project

## Commit Convention

This project strictly follows [Conventional Commits](https://www.conventionalcommits.org/) specification.

All commit messages MUST follow this format:
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Common types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `perf`, `ci`

## Plugin Version Management

**MANDATORY**: When updating any skill file, you MUST bump the version number in BOTH:

1. `.claude-plugin/plugin.json` - Update the `version` field
2. `.claude-plugin/marketplace.json` - Update the `plugins[].version` field

Version format follows semantic versioning (MAJOR.MINOR.PATCH):
- **PATCH**: Bug fixes, documentation updates, minor tweaks to existing skills
- **MINOR**: New features, new skills added, backwards-compatible changes
- **MAJOR**: Breaking changes to skill interfaces or behavior

### Example Workflow

When you modify a skill:

```bash
# 1. Edit the skill file
vi skills/personal-plan/skill.md

# 2. Update version in both JSON files
# .claude-plugin/plugin.json: "version": "0.5.1" → "0.5.2"
# .claude-plugin/marketplace.json: "plugins[0].version": "0.5.1" → "0.5.2"

# 3. Commit with conventional format
git commit -m "feat(personal-plan): add new trigger for daily review"
```

**Important**: Always keep the version numbers in `plugin.json` and `marketplace.json` synchronized.

## Testing

Before committing skill changes:
- Run relevant tests in `tests/` directory
- Manually verify the skill works in Claude Code session
- Check that skill triggers activate correctly

## Development Notes

- Skills are located in `skills/` directory
- Each skill should have clear trigger keywords in its description
- Keep skill documentation concise and actionable
- Test skills with real-world use cases before publishing
