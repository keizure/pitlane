#!/usr/bin/env python3
"""
Semantic Release - 智能版本分析和标签生成

分析 git commits 和 diff，由 Claude 智能生成高质量的 release notes
"""

import argparse
import subprocess
import sys
import re
import json
import os
import tempfile
from typing import Tuple, List, Dict, Optional
from enum import Enum
from pathlib import Path


class VersionBump(Enum):
    """版本升级类型"""

    MAJOR = 'major'  # 破坏性变更
    MINOR = 'minor'  # 新功能
    PATCH = 'patch'  # 修复


class CommitAnalyzer:
    """Commit 分析器 - 基于约定式提交"""

    # Conventional Commits 关键词
    BREAKING_PATTERNS = [
        r'BREAKING[- ]CHANGE',
        r'!:',  # feat!: 这种格式
    ]

    FEATURE_PATTERNS = [
        r'^feat(\(.+\))?:',
        r'^feature(\(.+\))?:',
    ]

    FIX_PATTERNS = [
        r'^fix(\(.+\))?:',
        r'^bugfix(\(.+\))?:',
    ]

    def __init__(self, commits: List[str]):
        self.commits = commits
        self.breaking_changes = []
        self.features = []
        self.fixes = []
        self.others = []

    def analyze(self) -> Tuple[VersionBump, bool]:
        """分析所有 commits，确定版本升级类型

        Returns:
            (VersionBump, is_uncertain): 版本类型和是否不确定（需要人工审查）
        """
        for commit in self.commits:
            commit_lower = commit.lower()

            # 检查破坏性变更
            if any(
                re.search(pattern, commit, re.IGNORECASE)
                for pattern in self.BREAKING_PATTERNS
            ):
                self.breaking_changes.append(commit)
            # 检查新功能
            elif any(
                re.search(pattern, commit_lower) for pattern in self.FEATURE_PATTERNS
            ):
                self.features.append(commit)
            # 检查修复
            elif any(re.search(pattern, commit_lower) for pattern in self.FIX_PATTERNS):
                self.fixes.append(commit)
            else:
                self.others.append(commit)

        # 确定版本类型
        if self.breaking_changes:
            return VersionBump.MAJOR, False
        elif self.features:
            return VersionBump.MINOR, False
        elif self.fixes:
            return VersionBump.PATCH, False
        else:
            # 如果没有明确关键词，使用保守策略（PATCH）但标记为不确定
            if self.others:
                return VersionBump.PATCH, True
            # 完全没有提交，默认 patch
            return VersionBump.PATCH, False

    def get_summary(self) -> Dict[str, List[str]]:
        """获取分析摘要"""
        return {
            'breaking': self.breaking_changes,
            'features': self.features,
            'fixes': self.fixes,
            'others': self.others,
        }


def run_command(cmd: List[str], cwd: str = None) -> Tuple[bool, str]:
    """运行命令并返回结果"""
    try:
        result = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, check=False
        )
        return result.returncode == 0, result.stdout.strip()
    except Exception as e:
        return False, str(e)


def get_current_branch() -> str:
    """获取当前分支名称"""
    success, branch = run_command(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])
    if not success:
        print('❌ 无法获取当前分支')
        sys.exit(1)
    return branch


def update_main_branch(branch: str = 'master'):
    """更新主干分支"""
    print(f'\n📥 更新主干分支 ({branch})...')

    # 获取当前分支
    current_branch = get_current_branch()

    # 如果不在主干分支，先切换
    if current_branch != branch:
        print(f'   切换到 {branch} 分支...')
        success, output = run_command(['git', 'checkout', branch])
        if not success:
            print(f'❌ 切换分支失败: {output}')
            sys.exit(1)

    # 拉取最新代码
    print(f'   拉取最新代码...')
    success, output = run_command(['git', 'pull', 'origin', branch])
    if not success:
        print(f'❌ 拉取失败: {output}')
        sys.exit(1)

    print(f'✓ 分支已更新')


def get_latest_tag() -> Optional[str]:
    """获取最新的 tag"""
    success, tag = run_command(['git', 'describe', '--tags', '--abbrev=0'])
    if success:
        return tag
    return None


def parse_version(version_str: str) -> Tuple[int, int, int]:
    """解析版本号字符串"""
    # 移除 'v' 前缀（如果有）
    version_str = version_str.lstrip('v')

    match = re.match(r'(\d+)\.(\d+)\.(\d+)', version_str)
    if match:
        return int(match.group(1)), int(match.group(2)), int(match.group(3))

    return 0, 0, 0


def bump_version(current_version: str, bump_type: VersionBump) -> str:
    """根据类型升级版本号"""
    major, minor, patch = parse_version(current_version)

    if bump_type == VersionBump.MAJOR:
        return f'v{major + 1}.0.0'
    elif bump_type == VersionBump.MINOR:
        return f'v{major}.{minor + 1}.0'
    else:  # PATCH
        return f'v{major}.{minor}.{patch + 1}'


def get_commits_since_tag(tag: Optional[str]) -> List[str]:
    """获取自指定 tag 以来的所有 commit messages"""
    if tag:
        cmd = ['git', 'log', f'{tag}..HEAD', '--pretty=format:%s']
    else:
        cmd = ['git', 'log', '--pretty=format:%s']

    success, output = run_command(cmd)
    if not success:
        return []

    return [line for line in output.split('\n') if line.strip()]


def get_diff_stats(tag: Optional[str]) -> str:
    """获取 diff 统计信息"""
    if tag:
        cmd = ['git', 'diff', '--stat', tag, 'HEAD']
    else:
        cmd = ['git', 'diff', '--stat', '--cached']

    success, output = run_command(cmd)
    return output if success else ''


def get_diff_content(tag: Optional[str]) -> str:
    """获取完整 diff 内容（用于 AI 分析）"""
    if tag:
        cmd = ['git', 'diff', tag, 'HEAD']
    else:
        cmd = ['git', 'diff', '--cached']

    success, output = run_command(cmd)
    return output if success else ''


def generate_release_notes_template(
    version: str,
    commits: List[str],
    diff_content: str,
    diff_stats: str,
    analyzer: 'CommitAnalyzer',
) -> str:
    """生成 release notes 模板供 Claude 编辑"""
    summary = analyzer.get_summary()

    template = f"""# Release Notes for {version}

请基于以下信息生成高质量的 release notes。
**注意：** 不要简单罗列 commits，而是要提炼出真正的功能变化和价值。

## 版本信息
- 版本号: {version}
- 总提交数: {len(commits)}
  - 破坏性变更: {len(summary['breaking'])}
  - 新功能: {len(summary['features'])}
  - 修复: {len(summary['fixes'])}
  - 其他: {len(summary['others'])}

## Commit Messages

"""

    # 按类别列出 commits
    if summary['breaking']:
        template += '### 破坏性变更\n'
        for commit in summary['breaking']:
            template += f'- {commit}\n'
        template += '\n'

    if summary['features']:
        template += '### 新功能\n'
        for commit in summary['features']:
            template += f'- {commit}\n'
        template += '\n'

    if summary['fixes']:
        template += '### 修复\n'
        for commit in summary['fixes']:
            template += f'- {commit}\n'
        template += '\n'

    if summary['others']:
        template += '### 其他变更\n'
        for commit in summary['others']:
            template += f'- {commit}\n'
        template += '\n'

    # 添加 diff 统计
    template += f"""## 代码变更统计

```
{diff_stats}
```

## 详细 Diff

<details>
<summary>点击查看完整 diff（可能很长）</summary>

```diff
{diff_content[:5000]}
{f'... (还有 {len(diff_content) - 5000} 字符)' if len(diff_content) > 5000 else ''}
```

</details>

---

## 请在下方编写 Release Notes

**格式要求：**
1. 用简洁的语言总结主要变化
2. 聚焦于用户可见的功能和改进
3. 不要简单复制 commit messages
4. 使用 Markdown 格式
5. 仅在最后用一个小节写 “Developer Notes（可选）”，其中可以包含：
   - 新增模块/目录
   - 重要实现说明
   - 大致代码量（可用区间/量级，避免精确行数刷屏）
6. **不要主观评价**（不要出现“很棒/非常优秀/史诗级”等），只写事实与影响。
7. 不要在最后再写一句话总结（例如 “总之这是一次重要更新” 之类）。
8. 如果 diff 信息不足以确定某些事实，使用“未知/请确认”的措辞，不要编造。

**示例：**
```markdown
Release {version}

## Overview
<1-2 句：这次发布的核心变化与对用户的影响>

**变更内容：**
- <2-5 条要点：用户可见能力/行为变化>

**Developer Notes: (optional)**
- <新增目录/关键文件（只列 3-8 条）>
- <实现要点（1-3 条）>

```

---

# 👇 在此处编写最终的 Release Notes

"""

    return template


def save_template_and_wait(template: str, version: str) -> str:
    """保存模板到临时文件，返回文件路径"""
    # 使用用户主目录下的 .cache/release-tag 目录
    release_dir = Path.home() / '.cache' / 'release-tag'
    release_dir.mkdir(parents=True, exist_ok=True)

    template_file = release_dir / f'{version}.md'

    with open(template_file, 'w', encoding='utf-8') as f:
        f.write(template)

    return str(template_file)


def read_release_notes(file_path: str) -> str:
    """读取 Claude 编辑后的 release notes"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取 "在此处编写最终的 Release Notes" 之后的内容
    marker = '# 👇 在此处编写最终的 Release Notes'
    if marker in content:
        parts = content.split(marker)
        if len(parts) > 1:
            release_notes = parts[1].strip()
            if release_notes:
                return release_notes

    # 如果没有找到标记，返回整个文件内容
    return content.strip()


def create_tag(version: str, description: str, push: bool = False):
    """创建 git tag"""
    print(f'\n🏷️  创建标签 {version}...')

    # 创建 annotated tag
    success, output = run_command(['git', 'tag', '-a', version, '-m', description])
    if not success:
        print(f'❌ 创建标签失败: {output}')
        sys.exit(1)

    print(f'✓ 标签已创建: {version}')

    if push:
        print(f'\n📤 推送标签到远程...')
        success, output = run_command(['git', 'push', 'origin', version])
        if not success:
            print(f'❌ 推送失败: {output}')
            sys.exit(1)
        print(f'✓ 标签已推送')


def main():
    parser = argparse.ArgumentParser(
        description='智能分析 git history 并生成语义化版本标签'
    )
    parser.add_argument(
        '--branch', default='master', help='主干分支名称（默认: master）'
    )
    parser.add_argument(
        '--dry-run', action='store_true', help='仅分析不创建标签（用于预览）'
    )
    parser.add_argument('--push', action='store_true', help='创建后自动推送到远程')
    parser.add_argument('--no-update', action='store_true', help='跳过分支更新步骤')
    parser.add_argument(
        '--version-type',
        choices=['major', 'minor', 'patch'],
        help='覆盖自动判断的版本类型',
    )
    parser.add_argument(
        '--message-file', help='使用指定文件的内容作为 release notes（跳过模板生成）'
    )

    args = parser.parse_args()

    print('🚀 语义化版本分析器')
    print('=' * 60)

    # 1. 更新主干分支
    if not args.no_update:
        update_main_branch(args.branch)
    else:
        print('\n⏭️  跳过分支更新')

    # 2. 获取最新 tag
    print('\n🔍 获取版本信息...')
    latest_tag = get_latest_tag()
    if latest_tag:
        print(f'   当前版本: {latest_tag}')
    else:
        print(f'   未找到现有标签，将创建初始版本')
        latest_tag = 'v0.0.0'

    # 3. 获取 commits
    print(f'\n📝 分析提交历史...')
    commits = get_commits_since_tag(latest_tag if latest_tag != 'v0.0.0' else None)

    if not commits:
        print('❌ 没有新的提交，无需创建新版本')
        sys.exit(0)

    print(f'   找到 {len(commits)} 个提交')

    # 4. 分析 commits
    analyzer = CommitAnalyzer(commits)
    bump_type, is_uncertain = analyzer.analyze()

    summary = analyzer.get_summary()
    print(f'\n   📊 提交分析:')
    print(f'      破坏性变更: {len(summary["breaking"])}')
    print(f'      新功能: {len(summary["features"])}')
    print(f'      修复: {len(summary["fixes"])}')
    print(f'      其他: {len(summary["others"])}')

    # 如果用户手动指定了版本类型，覆盖自动判断
    if args.version_type:
        version_map = {
            'major': VersionBump.MAJOR,
            'minor': VersionBump.MINOR,
            'patch': VersionBump.PATCH,
        }
        bump_type = version_map[args.version_type]
        is_uncertain = False
        print(f'\n   ✓ 使用指定的版本类型: {bump_type.value}')

    # 5. 计算新版本号
    new_version = bump_version(latest_tag, bump_type)
    print(f'\n   📈 版本升级类型: {bump_type.value}')
    print(f'   📦 新版本号: {new_version}')

    # 如果版本判断不确定，输出 Claude 分析所需信息
    if is_uncertain and not args.version_type:
        print('\n' + '=' * 60)
        print('⚠️  版本类型使用保守策略（PATCH），请审查')
        print('=' * 60)

        print('\n📋 未识别关键词的提交:')
        for commit in summary['others']:
            print(f'  - {commit}')

        print('\n📊 代码变更:')
        diff_content = get_diff_content(latest_tag if latest_tag != 'v0.0.0' else None)

        # 限制显示长度
        max_display = 2000
        if len(diff_content) > max_display:
            print(diff_content[:max_display])
            print(f'\n... (还有 {len(diff_content) - max_display} 字符)')
        else:
            print(diff_content)

        print('\n' + '=' * 60)
        print('🤖 Claude 分析指南:')
        print('   如果以上变更包含:')
        print('   - 破坏性变更 → 应使用 MAJOR')
        print('   - 新功能（向后兼容）→ 应使用 MINOR')
        print('   - 仅修复/文档/重构 → PATCH 正确')
        print('\n   如需修改版本类型，请使用 --version-type 参数重新运行')
        print('=' * 60)

    # 6. 获取 diff 内容
    diff_stats = get_diff_stats(latest_tag if latest_tag != 'v0.0.0' else None)
    diff_content = get_diff_content(latest_tag if latest_tag != 'v0.0.0' else None)

    # 7. 处理 release notes
    if args.message_file:
        # 使用指定的 message 文件
        print(f'\n📄 使用 release notes 文件: {args.message_file}')
        try:
            description = read_release_notes(args.message_file)
        except Exception as e:
            print(f'❌ 读取文件失败: {e}')
            sys.exit(1)
    else:
        # 生成模板并退出，等待 Claude 编辑
        template = generate_release_notes_template(
            new_version, commits, diff_content, diff_stats, analyzer
        )

        template_file = save_template_and_wait(template, new_version)

        print('\n' + '=' * 60)
        print('📝 Release Notes 模板已生成')
        print('=' * 60)
        print(f'文件位置: {template_file}')
        print('\n请编辑此文件，在标记处填写高质量的 release notes')
        print('编辑完成后，使用以下命令创建标签：')
        print(
            f'\n  python {sys.argv[0]} --message-file {template_file} {" ".join([a for a in sys.argv[1:] if "--dry-run" not in a])}'
        )
        print('=' * 60)
        sys.exit(0)

    print('\n' + '=' * 60)
    print('📋 Release Notes:')
    print('=' * 60)
    print(description)
    print('=' * 60)

    # 8. 创建标签
    if args.dry_run:
        print('\n🔍 预览模式 - 未创建标签')
        if is_uncertain:
            print('\n💡 提示: 如果版本类型不正确，使用 --version-type 参数覆盖')
    else:
        create_tag(new_version, description, args.push)
        print(f'\n✅ 标签已创建: {new_version}')

        if is_uncertain:
            print('\n💡 提示: 如果版本类型不正确，可以:')
            print(f'   1. 删除标签: git tag -d {new_version}')
            print(
                f'   2. 重新运行: python {sys.argv[0]} --version-type <major|minor|patch>'
            )


if __name__ == '__main__':
    main()
