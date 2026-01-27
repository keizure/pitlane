# Conventional Commits 规范

## 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type 类型

### 影响版本号的类型

| Type | 说明 | 版本升级 | 示例 |
|------|------|---------|------|
| `feat` | 新功能 | MINOR | `feat: 添加用户登录功能` |
| `fix` | Bug 修复 | PATCH | `fix: 修复登录失败问题` |
| `BREAKING CHANGE` | 破坏性变更 | MAJOR | `feat!: 重构 API 接口` |

### 不影响版本号的类型

| Type | 说明 |
|------|------|
| `docs` | 文档变更 |
| `style` | 代码格式（不影响代码运行） |
| `refactor` | 重构（既不修复 bug 也不添加功能） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建过程或辅助工具的变动 |
| `ci` | CI 配置文件和脚本的变动 |

## 破坏性变更标记

两种方式标记 BREAKING CHANGE：

### 1. 使用 `!`

```
feat!: 重构用户认证系统

旧的 login() 方法已删除，使用新的 authenticate()
```

### 2. 在 footer 中声明

```
feat: 重构用户认证系统

BREAKING CHANGE: 旧的 login() 方法已删除，使用新的 authenticate()
```

## 完整示例

### Minor 版本（新功能）

```
feat(auth): 添加 OAuth2 登录支持

- 支持 Google OAuth2
- 支持 GitHub OAuth2
- 添加第三方登录配置界面

Closes #123
```

### Patch 版本（修复）

```
fix(api): 修复用户数据查询失败

当用户 ID 包含特殊字符时，查询会失败。
现在正确处理了 URL 编码。

Fixes #456
```

### Major 版本（破坏性变更）

```
feat(api)!: 重构 REST API 端点

BREAKING CHANGE:
- /api/users 改为 /api/v2/users
- 响应格式从数组改为带分页的对象
- 移除已废弃的 /api/user_list 端点

迁移指南: docs/migration-v2.md
```

## 最佳实践

1. **Subject 行**
   - 使用祈使句："添加功能" 而非 "添加了功能"
   - 不要大写首字母
   - 不要以句号结尾
   - 限制在 50 个字符以内

2. **Body**
   - 解释"是什么"和"为什么"，而非"怎么做"
   - 与 subject 行空一行
   - 每行限制在 72 个字符以内

3. **Footer**
   - 引用相关 issue: `Closes #123` 或 `Fixes #456`
   - 标记破坏性变更: `BREAKING CHANGE:`

## 工具推荐

- **commitizen** - 交互式创建符合规范的 commit
- **commitlint** - 验证 commit message 格式
- **standard-version** - 自动生成 CHANGELOG 和版本号
