# 语义化版本策略

## 版本号格式

```
vMAJOR.MINOR.PATCH
```

例如: `v1.2.3`

## 版本升级规则

### MAJOR 版本（主版本）

**何时升级：** 破坏性变更（Breaking Changes）

**示例：**
- 移除公共 API
- 改变 API 行为导致不兼容
- 重命名核心模块或函数
- 修改配置文件格式
- 数据库 schema 重大变更

**Commit 特征：**
- `feat!:` 或 `fix!:`
- 包含 `BREAKING CHANGE:` footer
- 关键词: "remove", "rename", "refactor API", "incompatible" (仅作为辅助判断)

**示例版本变化：**
- `v1.9.5` → `v2.0.0`
- `v0.3.2` → `v1.0.0` (首次稳定版本)

### MINOR 版本（次版本）

**何时升级：** 向后兼容的新功能

**示例：**
- 添加新的公共 API
- 新增功能模块
- 新增配置选项（可选）
- 添加新的命令行参数

**Commit 特征：**
- `feat:` 前缀
- 关键词: "add", "implement", "support", "introduce"

**示例版本变化：**
- `v1.2.5` → `v1.3.0`
- `v2.0.0` → `v2.1.0`

### PATCH 版本（修订版本）

**何时升级：** 向后兼容的 bug 修复

**示例：**
- 修复错误行为
- 性能优化
- 文档更新
- 代码重构（不改变行为）
- 依赖更新

**Commit 特征：**
- `fix:` 前缀
- `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `chore:`
- 关键词: "fix", "correct", "resolve", "patch"

**示例版本变化：**
- `v1.2.3` → `v1.2.4`
- `v2.5.0` → `v2.5.1`

## 判断流程

```
┌─────────────────────────────┐
│  分析 commit messages       │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│ 是否包含 BREAKING CHANGE?   │
│ - feat!: / fix!:            │
│ - BREAKING CHANGE: footer   │
└──────────┬──────────────────┘
           │
    Yes ───┴─── No
     │           │
     ▼           ▼
┌─────────┐ ┌─────────────────┐
│ MAJOR   │ │ 是否包含 feat:? │
└─────────┘ └────────┬────────┘
                     │
              Yes ───┴─── No
               │           │
               ▼           ▼
          ┌────────┐  ┌───────┐
          │ MINOR  │  │ PATCH │
          └────────┘  └───────┘
```

## 特殊情况

### 0.x.x 版本（开发阶段）

在 `v0.x.x` 阶段，版本规则更宽松：
- MINOR 可能包含破坏性变更
- 表示 API 尚未稳定
- 首个稳定版本应为 `v1.0.0`

### 多个类型混合

如果一次发布包含多种类型的提交，选择**最高级别**：

```
BREAKING CHANGE > feat > fix > others
    (MAJOR)      (MINOR) (PATCH)
```

**示例：**
```bash
# 包含 3 个 feat 和 2 个 fix
# 结果: MINOR (v1.2.0 → v1.3.0)

# 包含 1 个 feat! 和 5 个 feat
# 结果: MAJOR (v1.2.0 → v2.0.0)
```

### 无明确关键词

如果 commits 都没有明确的类型前缀（不推荐）：
- 默认升级 **PATCH** 版本
- 建议使用 AI 分析 diff 内容

## 最佳实践

### ✅ 推荐做法

1. **严格遵循 Conventional Commits**
   - 让版本升级自动化和可预测

2. **谨慎对待 BREAKING CHANGE**
   - 尽量避免在 MINOR 版本引入
   - 提供迁移指南

3. **每个发布聚焦单一目标**
   - 不要混合太多不同类型的变更
   - 更容易编写 CHANGELOG

4. **使用里程碑规划 MAJOR 版本**
   - 收集足够的破坏性变更一起发布
   - 减少用户升级频率

### ❌ 避免做法

1. **随意升级 MAJOR 版本**
   - 小改动不要轻易升级 MAJOR

2. **在 PATCH 版本添加新功能**
   - 违反语义化版本原则

3. **忽略 BREAKING CHANGE 标记**
   - 导致用户意外遇到兼容性问题

## 示例场景

### 场景 1: 功能发布

```bash
# Commits:
# - feat: 添加导出 PDF 功能
# - feat: 支持自定义主题
# - fix: 修复导出时的编码问题
# - docs: 更新使用文档

# 分析:
# - 有 feat 但无 BREAKING CHANGE
# - 结果: MINOR
# - v1.5.3 → v1.6.0
```

### 场景 2: 热修复

```bash
# Commits:
# - fix: 修复安全漏洞 CVE-2024-1234
# - fix: 修复内存泄漏问题

# 分析:
# - 只有 fix
# - 结果: PATCH
# - v2.3.1 → v2.3.2
```

### 场景 3: 重大重构

```bash
# Commits:
# - feat!: 重构存储层架构
# - feat: 新增 S3 存储支持
# - fix: 修复旧 API 兼容性问题
#
# BREAKING CHANGE:
# - 移除 legacy_storage 模块
# - 配置文件格式变更

# 分析:
# - 有 feat! 和 BREAKING CHANGE
# - 结果: MAJOR
# - v1.9.8 → v2.0.0
```

## 参考资源

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
