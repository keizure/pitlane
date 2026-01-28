# Contributing to Pitlane

Thank you for your interest in contributing to Pitlane!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/pitlane.git
cd pitlane

# Configure git
git config user.name "Your Name"
git config user.email "your@email.com"
```

## Making Changes

### Modifying Skills

Skills are located in `skills/` directory. Each skill has:
- `SKILL.md` - The main skill prompt and documentation
- `references/` - Optional reference documentation

When modifying a skill:
1. Update `SKILL.md` with your changes
2. Test using fixtures: `cd tests/fixtures/basic && ./setup.sh`
3. Run automated tests: `cd tests && ./run_tests.sh`
4. Update version in `.claude-plugin/plugin.json` if needed

### SKILL.md Format

```yaml
---
name: skill-name
description: "Brief description. Triggers: 'keyword1', 'keyword2'."
---

# Skill Name

[Skill content here]
```

Required fields:
- `name`: Unique skill identifier
- `description`: Brief description with triggers/keywords

## Testing

### Run All Tests
```bash
cd tests
./run_tests.sh
```

### Test Individual Fixtures
```bash
cd tests/fixtures/basic
./setup.sh
# Then test manually with Claude Code
```

### Add New Tests

1. Create fixture setup script in `tests/fixtures/NEW_SCENARIO/setup.sh`
2. Add test case in `tests/integration/test_release_tag.sh`
3. Document expected behavior in `tests/README.md`

## Pull Request Guidelines

### Before Submitting

- [ ] All tests pass
- [ ] Manual testing completed
- [ ] Documentation updated
- [ ] Version bumped if needed (plugin.json)
- [ ] Conventional commit messages used

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: fix bug in version detection
docs: update README
chore: update dependencies
test: add test for breaking changes
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Automated tests pass
- [ ] Manual testing completed
- [ ] New tests added (if applicable)

## Checklist
- [ ] Code follows project conventions
- [ ] Documentation updated
- [ ] Version bumped (if needed)
```

## Code Review Process

1. Submit PR with clear description
2. Wait for CI checks to pass
3. Address reviewer feedback
4. Maintainer will merge when approved

## Release Process

Releases are managed using the `release-tag` skill:

1. Ensure all changes are committed
2. Run `/release-tag` in Claude Code
3. Review generated release notes
4. Approve tag creation
5. Push tag to remote

## Questions?

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones
- Be respectful and constructive

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
