---
name: personal-plan
description: "Personal information capture and daily planning system based on .plan file format. Use when: (0) User call personal-plan, (1) Recording daily work/ideas, (2) Capturing thoughts quickly, (3) Reviewing progress, (4) Organizing scattered information. Triggers: '记下来', '今天做了什么', '想法', 'capture', 'log today', 'what did I do', 'plan review'."
disable-model-invocation: false
---

# Personal Plan (Daily Information Capture)

This skill helps you maintain a **personal .plan file system** for capturing daily work, ideas, and progress in a simple, friction-free way.

## Philosophy (The .plan Way)

Based on the original .plan file concept:
- **Simplicity first**: Plain text, minimal syntax, no overhead
- **Capture fast**: Record now, organize later
- **Natural accumulation**: Let patterns emerge organically
- **Single source of truth**: One place for all your daily context

## Non-Negotiable Rules

1. **Never lose data**: Always read existing content before writing
2. **Preserve format**: Keep existing entries intact when adding new ones
3. **Date-based organization**: Always use ISO date format (YYYY-MM-DD)
4. **Minimal syntax**: Use only the markers defined in this skill
5. **No perfectionism**: Better to capture imperfectly than not at all

## File Structure

The system uses a single daily log file with optional topic files:

```
~/.plan/
├── daily.plan          # Daily stream (primary file)
├── index.md            # Quick reference index (optional)
├── projects/           # Project-specific notes (optional)
└── archive/            # Archived content (optional)
```

## Core Workflow

### When user wants to CAPTURE (记录/记下来)

**Triggers**: "记下来", "log this", "capture", "记录一下"

**Actions**:
1. Determine what to record (ask if unclear)
2. Read current `daily.plan` file
3. Add new entry under today's date section
4. Use appropriate marker (see below)
5. Save and confirm

### When user wants to REVIEW (回顾)

**Triggers**: "今天做了什么", "what did I do", "review", "回顾"

**Actions**:
1. Read `daily.plan`
2. Find today's section
3. Summarize:
   - Completed items (*)
   - Open todos (?)
   - Ideas captured
   - Abandoned items (~)

### When user wants to PLAN (计划)

**Triggers**: "明天做什么", "plan tomorrow", "todo"

**Actions**:
1. Read `daily.plan`
2. Add tomorrow's date section
3. Add todo items with `?` marker
4. Optionally link to projects

## Syntax (Minimal Markers)

Use these markers at the start of a line:

- `*` - Completed item (已完成)
- `?` - Todo / Question (待办/疑问)
- `+` - Fixed / Resolved (已修复)
- `~` - Abandoned / Postponed (放弃/延后)
- `[tag1, tag2, ...]` - Multi-tag system (标签系统)
- `---` - Topic separator (话题分隔)

## Tag System

### Tag Format
- **Single tag**: `[project]` or `[bug]` or `[feature]`
- **Multiple tags**: `[project, bug, urgent]` or `[livery-cv, frontend, ui]`
- **User manual tags**: User says "#bug #urgent" → record as `[bug, urgent]`
- **Auto-detect tags**: If user mentions project names, auto-add corresponding tags

### Tag Rules
1. **Manual tags first**: User's explicit `#tag` must be preserved
2. **Auto-detect supplement**: If no manual tags, Claude auto-detects and adds
3. **Tag order**: `[project, type, attribute]` - project > type > attribute
4. **Lowercase with hyphens**: Use lowercase and hyphens (e.g., `livery-cv`)
5. **No duplicates**: Remove duplicate tags when merging manual + auto tags

### Common Tags Reference

**Projects** (auto-detect from mentions):
- `pitlane` - pitlane plugin project
- `livery-cv` - livery-cv resume project
- `lianshan-agents` - lianshan-agents translation project
- `mcp` - MCP server related work

**Types**:
- `feature` - new feature development
- `bug` - bug fix
- `docs` - documentation
- `refactor` - code refactoring
- `chore` - maintenance tasks
- `test` - testing work

### Tag Examples

```markdown
## 2026-02-28

* [pitlane, docs] 添加 CLAUDE.md 版本管理规则
  User said: "记下来，添加了版本管理规则 #docs"

* [livery-cv, bug, urgent] 修复语言切换器在移动端的显示问题
  User said: "#bug #urgent 修复了 livery-cv 的切换器问题"

* [mcp, troubleshooting] 解决 Chrome DevTools 连接问题
  User said: "记下来，解决了 MCP 连接问题"
  (auto-detected: mcp, troubleshooting)

? [lianshan-agents, code-review] review 翻译 agent MR#4
  User said: "待办：review lianshan-agents 的 MR#4"
  (auto-detected: lianshan-agents, code-review)

* [idea] 用 Claude Code 技能系统管理个人知识
  User said: "想法：用 Claude 管理知识"
  (auto-detected: idea)
```

**Example daily.plan**:
```markdown
## 2026-02-27

* 看了 .plan 文章，很有启发
? [idea] 设计个人信息系统
* [pitlane, feature] 创建 personal-plan 技能
~ [notion] 笔记整理（太耗时，延后）

---

想法：用 Claude Code 技能系统管理个人知识
可以做一个 knowledge-capture 技能

---

## 2026-02-26

* [lianshan-agents, bug] 修复翻译 bug
? [research] 研究 LangGraph 架构
```

## Default File Location

**Primary file**: `~/.plan/daily.plan`

If the file doesn't exist:
1. Ask user to confirm location (default: `~/.plan/daily.plan`)
2. Create directory if needed
3. Initialize with today's date section

## Phase 1 — Capture

### Step 1 — Understand intent
Ask clarifying questions if needed:
- What do you want to record?
- Is this a completed item, todo, or just a thought?
- Does it belong to a specific project?

### Step 2 — Read existing file
```bash
cat ~/.plan/daily.plan
```

If file doesn't exist, proceed to initialization.

### Step 3 — Determine today's section
Check if today's date section exists (format: `## YYYY-MM-DD`)

If not, create new section at the top of the file.

### Step 4 — Add new entry

**Tag Processing**:
1. Extract manual tags from user's message (all `#tag` patterns)
2. Auto-detect tags based on:
   - Project mentions (pitlane, livery-cv, lianshan-agents, mcp)
   - Type keywords (bug, feature, docs, refactor, idea, research)
   - Domain keywords (frontend, backend, ui, devops)
   - Action words (troubleshooting, code-review, blocked, urgent)
3. Merge manual + auto tags, remove duplicates
4. Order tags: `[project, type, attribute]`
5. Format as `[tag1, tag2, tag3]` if multiple tags exist

Place new entry in appropriate section with correct marker and tags.

### Step 5 — Write back
Save the updated content.

**Important**: Use exact format, preserve all existing content.

### Step 6 — Confirm
Show what was added to the user.

## Phase 2 — Review

### Step 1 — Read daily.plan
```bash
cat ~/.plan/daily.plan
```

### Step 2 — Find relevant section
- For "today": current date section
- For "yesterday": previous date
- For "this week": all entries from last 7 days
- For "recent": last 3 date sections

### Step 3 — Summarize
Present in natural language:
- What was completed (count + highlights)
- What's still open (todos)
- Key ideas or questions captured
- Any abandoned/postponed items

## Phase 3 — Plan

### Step 1 — Read current plan
```bash
cat ~/.plan/daily.plan
```

### Step 2 — Create next day section
If user wants to plan tomorrow, add new date section.

### Step 3 — Add todos
For each todo item, add with `?` marker.

### Step 4 — Link to context
If related to existing work, reference the project.

**Example**:
```markdown
## 2026-02-27

? 整理产品设计文档
  参考: https://notion.so/product-design-xyz
```

## Common Use Cases

### Case 1: Quick idea capture
User: "记下来：用 MCP 做翻译质量检查"

Response:
- Read daily.plan
- Extract tags: auto-detect `mcp`, `idea`
- Add under today's date with tags: `* [mcp, idea] 用 MCP 做翻译质量检查`

### Case 2: Log completed work with manual tags
User: "今天完成了翻译系统的上下文功能 #feature"

Response:
- Read daily.plan
- Extract tags: manual `feature`, auto-detect `lianshan-agents` (if mentioned in context)
- Add with `*` marker: `* [lianshan-agents, feature] 完成翻译系统的上下文功能`

### Case 3: Multiple manual tags
User: "#bug #urgent 修复了 livery-cv 的语言切换器"

Response:
- Read daily.plan
- Extract tags: manual `bug`, `urgent`, auto-detect `livery-cv`
- Add: `* [livery-cv, bug, urgent] 修复语言切换器`

### Case 3: Daily review
User: "今天做了什么"

Response:
- Read today's section
- Summarize completed items
- Highlight open todos

### Case 4: Weekly planning
User: "这周要做的事"

Response:
- Read last 7 days
- Collect all `?` items
- Optionally create weekly summary

## Error Handling

### File not found
If `~/.plan/daily.plan` doesn't exist:
1. Ask: "Should I create .plan file at ~/.plan/daily.plan?"
2. If yes: create directory + file with today's section
3. If no: ask for alternative location

### Corrupted format
If file format is unexpected:
1. Show current content to user
2. Ask: "Format looks unusual, should I normalize it?"
3. Always preserve original in backup before modification

### Permission denied
If cannot write to file:
1. Check file permissions
2. Suggest alternative location
3. Never fail silently

## **DO NOT**

- ❌ Creating complex folder hierarchies upfront
- ❌ Asking too many questions before capturing
- ❌ Enforcing strict categorization
- ❌ Over-organizing before patterns emerge
- ❌ Migrating all Notion content at once
- ❌ Creating the file without asking user
- ❌ Losing or corrupting existing entries
