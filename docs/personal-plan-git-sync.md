# Personal Plan Git Sync 使用指南

## 概述

personal-plan skill 现已支持自动 Git 同步功能，可以将你的 .plan 文件自动备份到 GitHub。

## 工作原理

### 自动 Commit（每次记录时）

当你使用 personal-plan 记录信息时，系统会：

1. ✅ 写入内容到 `~/.plan/daily.plan`
2. ✅ 自动执行 `git commit`（本地操作，很快）
3. ✅ 保留完整的本地历史记录

**注意**：自动 commit 不会 push 到远程，不影响记录速度。

### 手动 Sync（需要时执行）

当你想同步到 GitHub 时，说：
- "同步计划"
- "sync plan"
- "push plan"

系统会执行：
1. `git pull --rebase` - 拉取远程最新更改
2. `git commit` - 提交本地未提交的修改（如有）
3. `git push` - 推送到远程仓库
4. 报告同步状态

## 使用示例

### 日常记录（自动 commit）

```
你: 记下来，完成了 SEO 优化任务
Claude: ✅ 已记录完成：[seo] 完成了 SEO 优化任务
       （已自动 commit 到本地仓库）
```

### 手动同步到远程

```
你: 同步计划
Claude:
  ⏬ Pulling latest changes...
  ✅ Committed local changes
  ⏫ Pushing to GitHub...
  ✅ Synced to GitHub successfully!
```

## 设置要求

确保 `~/.plan` 是指向 git 仓库的软链接：

```bash
~/.plan -> ~/dotplan/.plan  # dotplan 是 git 仓库
```

如果你的设置不同，系统会自动检测并适配。

## 故障排查

### 自动 commit 不工作

检查是否在 git 仓库中：
```bash
cd ~/dotplan
git status
```

### Sync 失败：冲突

如果多设备修改导致冲突：
```bash
cd ~/dotplan
git status
# 手动解决冲突
git add .plan/daily.plan
git rebase --continue
git push
```

### Push 被拒绝

如果远程有新提交：
```bash
cd ~/dotplan
git pull --rebase
git push
```

## 技术细节

### 自动 Commit 逻辑

```bash
# 检测 git 仓库
PLAN_DIR=$(dirname $(readlink -f ~/.plan/daily.plan))
cd "$PLAN_DIR/.."

# 提交更改
git add .plan/daily.plan
git commit -m "docs(plan): update at HH:MM" --quiet
```

### Sync 逻辑

```bash
cd ~/dotplan

# 拉取
git pull --rebase

# 提交（如有未提交的）
git add .plan/daily.plan
git commit -m "docs(plan): sync at $(date)"

# 推送
git push
```

## 最佳实践

1. **日常使用**：只管记录，不用担心同步
2. **每日一次**：工作结束时执行 "同步计划"
3. **多设备**：切换设备前先 sync，避免冲突
4. **定期备份**：GitHub 作为远程备份，本地依然是主要工作区

## Roadmap

未来可能支持：
- [ ] Session 结束时自动 sync
- [ ] 冲突自动解决
- [ ] Cron 定时 sync
- [ ] Sync 状态提示
