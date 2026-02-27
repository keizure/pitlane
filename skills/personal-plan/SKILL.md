---
name: personal-plan
description: "Personal information capture and daily planning system based on .plan file format. Use when: (1) Recording daily work/ideas, (2) Capturing thoughts quickly, (3) Reviewing progress, (4) Organizing scattered information. Triggers: '记下来', '今天做了什么', '想法', 'capture', 'log today', 'what did I do', 'plan review'."
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
- `[project]` - Project tag (项目标签)
- `---` - Topic separator (话题分隔)

**Example daily.plan**:
```markdown
## 2026-02-27

* 看了 .plan 文章，很有启发
? 设计个人信息系统
* [pitlane] 创建 personal-plan 技能
~ Notion 笔记整理（太耗时，延后）

---

想法：用 Claude Code 技能系统管理个人知识
可以做一个 knowledge-capture 技能

---

## 2026-02-26

* [lianshan-agents] 修复翻译 bug
? 研究 LangGraph 架构
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
Place new entry in appropriate section with correct marker.

If user mentioned a project, add `[project-name]` prefix.

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

## Integration with Notion (Optional)

If user mentions Notion content:
1. Don't auto-migrate everything
2. Suggest: "Add link to Notion page in .plan"
3. Use .plan as index/pointer to Notion when needed

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
- Add under today's date
- Use plain text (no marker) or `想法:` prefix

### Case 2: Log completed work
User: "今天完成了翻译系统的上下文功能"

Response:
- Read daily.plan
- Add with `*` marker
- Include project tag if applicable

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

## Output Examples

### After capturing:
```
✓ Added to ~/.plan/daily.plan

## 2026-02-27
* [pitlane] 创建 personal-plan 技能
```

### After review:
```
Today (2026-02-27):
- ✓ Completed: 2 items
  - Created personal-plan skill for pitlane
  - Fixed translation bug in lianshan-agents
- ⏸ Postponed: Notion migration (too time-consuming)
- 💡 Ideas: Use MCP for translation quality checks
```

## Anti-Patterns (Don't Do)

- ❌ Creating complex folder hierarchies upfront
- ❌ Asking too many questions before capturing
- ❌ Enforcing strict categorization
- ❌ Over-organizing before patterns emerge
- ❌ Migrating all Notion content at once
- ❌ Creating the file without asking user
- ❌ Losing or corrupting existing entries

## Extending the System (Future)

Once user has consistent daily.plan usage for 2+ weeks, consider:
- Weekly auto-summary script
- Project extraction to `projects/*.md`
- Archiving old entries
- Search/grep helpers
- RSS feed generation (like original .plan)

But don't implement these upfront. Let the need emerge naturally.

---

## Success Metrics

The skill is working well if:
- User can capture thoughts in < 30 seconds
- No questions about "which file" or "what format"
- User naturally starts using it daily
- Information feels organized without manual effort
- User prefers this over scattered note systems

---

## Quick Reference

| User says | Action |
|-----------|--------|
| 记下来/log this | Add to daily.plan with appropriate marker |
| 今天做了什么/what did I do | Review today's section |
| 计划明天/plan tomorrow | Create tomorrow's section with todos |
| 这周做了什么/weekly review | Summarize last 7 days |
