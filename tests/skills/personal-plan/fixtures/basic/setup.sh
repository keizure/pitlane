#!/bin/bash
set -e

# Setup script for basic personal-plan testing fixture
# This creates a sample .plan directory structure for manual testing

FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_DIR="$HOME/.plan-test"

echo "Setting up personal-plan test fixture..."

# Create directory structure
mkdir -p "$PLAN_DIR"

# Create sample daily.plan with multiple days
cat > "$PLAN_DIR/daily.plan" <<'EOF'
## 2026-02-27

* [pitlane] 创建 personal-plan 技能
* 研究 .plan 文件格式
? 添加测试用例
~ Notion 笔记迁移（延后）

---

想法：可以用 MCP 集成翻译质量检查

---

## 2026-02-26

* [lianshan-agents] 修复翻译 bug
* 完成 QA 系统设计文档
? 研究 LangGraph 架构

---

## 2026-02-25

* 日常代码审查
+ 修复 CI 流水线问题
? 准备周会分享

EOF

# Create optional index file
cat > "$PLAN_DIR/index.md" <<'EOF'
# Personal Plan Index

## Active Projects
- [pitlane](projects/pitlane.md) - Claude Code plugin development
- [lianshan-agents](projects/lianshan-agents.md) - Translation management system

## Quick Links
- [Daily Plan](daily.plan) - Current work log
- [Ideas](ideas.md) - Captured thoughts

EOF

# Create projects directory
mkdir -p "$PLAN_DIR/projects"

cat > "$PLAN_DIR/projects/pitlane.md" <<'EOF'
# Pitlane Project

Claude Code plugin repository for production-ready skills.

## Current Work
- personal-plan skill development
- release-tag optimization

## References
- Repo: https://github.com/keizure/pitlane
EOF

cat > "$PLAN_DIR/projects/lianshan-agents.md" <<'EOF'
# Lianshan Agents Project

Multi-repo gettext translation management system.

## Current Work
- Translation system QA design
- Context-aware translation

## References
- Repo: /Users/liangjinrun/work/lianshan-agents
EOF

echo ""
echo "✓ Fixture created at: $PLAN_DIR"
echo ""
echo "Test files created:"
echo "  - daily.plan (3 days of sample entries)"
echo "  - index.md (quick reference)"
echo "  - projects/pitlane.md"
echo "  - projects/lianshan-agents.md"
echo ""
echo "You can now test the personal-plan skill with:"
echo "  1. Open Claude Code in any directory"
echo "  2. Say: '查看我的 plan'"
echo "  3. Point to: $PLAN_DIR/daily.plan"
echo ""
echo "To clean up:"
echo "  rm -rf $PLAN_DIR"
