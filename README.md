# AgentMD

AgentMD 用一个仓库维护 Codex 和 Claude Code 的全局指令。公共行为写在同一份 `AGENTS.md` 中，细分规则放进 `global/rules/`，Windows 客户端和 Linux 服务器各自使用合适的分支与脚本。

它主要解决两个问题：一是避免在多个 Agent 配置目录里重复修改同一条规则；二是当本地指令文件已经包含其他来源的内容时，只同步 AgentMD 管理的部分，不覆盖其余内容。

## 从哪个分支开始

仓库维护两个使用分支：

| 分支 | 适用环境 | 内容 |
| --- | --- | --- |
| `main` | Windows、本地客户端 | 公共规则和 PowerShell 脚本 |
| `server` | Linux、服务器 | 服务器专用规则和 Bash 脚本 |

Windows 用户从 `main` 开始，Linux 服务器使用 `server`。公共规则先在 `main` 中维护；服务器是否采纳一项公共改动，取决于服务器环境是否需要它。

## 仓库结构

```text
AgentMD/
├─ global/
│  ├─ AGENTS.md          全局指令的唯一内容源
│  ├─ CLAUDE.md          指向 AGENTS.md 的软链接
│  └─ rules/             按条件读取的详细规则
├─ scripts/
│  ├─ install-links.ps1  首次安装与后续同步
│  └─ validate-links.ps1 检查安装状态和文档链接
├─ AGENTS.md             维护本仓库时使用的规则
└─ CLAUDE.md             指向根目录 AGENTS.md 的软链接
```

`AGENTS.md` 是每一层的内容源。对应的 `CLAUDE.md` 只负责让 Claude Code 读取同一份内容，不维护副本。只有需要同步到用户目录的 `global/AGENTS.md` 使用 `AGENTMD_START/END` 标记。

全局文件只保留每次任务都需要的约定，以及读取详细规则的触发条件。编码、范围控制和 Git 交付等较长说明位于 `global/rules/`，Agent 只在相关任务中读取它们。

## 安装位置

在 `main` 分支打开 PowerShell，运行：

```powershell
.\scripts\install-links.ps1
```

脚本会处理以下位置：

| 用户目录 | 仓库来源 |
| --- | --- |
| `%USERPROFILE%\.codex\AGENTS.md` | `global/AGENTS.md` |
| `%USERPROFILE%\.claude\CLAUDE.md` | `global/CLAUDE.md` |
| `%USERPROFILE%\.codex\rules\*.md` | `global/rules/*.md` |
| `%USERPROFILE%\.claude\rules\*.md` | `global/rules/*.md` |

目标不存在时，脚本创建软链接。这样修改仓库中的规则后，本地 Agent 会直接读到新内容。

## 共享指令文件

用户级指令文件有两种合法状态。

软链接表示整份文件由 AgentMD 管理。只要链接仍然指向本仓库，同步脚本不会替换它。

普通文件表示它已经成为共享文件。AgentMD 只更新下面两个标记之间的内容：

```markdown
<!-- AGENTMD_START -->
...AgentMD 管理的全局指令...
<!-- AGENTMD_END -->
```

标记之外的文字会保留下来，文件也继续保持普通文件，不会被转回软链接。

如果普通文件没有完整标记、标记重复或顺序错误，脚本会停止。指向未知位置的软链接也不会被接管。这些情况需要先由用户确认文件的实际归属。

`rules/*.md` 的文件名和完整内容由 AgentMD 管理。它们如果变成普通文件，同步脚本会原位更新内容，但仍保留普通文件形态。

## 更新与验证

修改 `global/AGENTS.md` 或 `global/rules/` 后，再次运行安装脚本：

```powershell
.\scripts\install-links.ps1
```

提交或推送只会更新仓库，不会更新用户目录。每台电脑拉取变更后都要运行安装脚本；普通用户级指令文件只更新 AgentMD 标记内的内容，CodeGraph 等标记外内容保持不变。

随后验证仓库链接、用户目录中的链接或托管副本，以及 Markdown 内的本地路径：

```powershell
.\scripts\validate-links.ps1
```

验证输出会区分 `linked` 和 `managed copy`。前者是软链接，后者是保留在用户目录中的普通文件。

如果同步失败，先看错误中指出的具体文件，再检查：

- 文件是否缺少 `AGENTMD_START/END` 标记；
- 同一个标记是否出现多次；
- 软链接是否指向另一个位置；
- Rules 普通文件是否尚未同步到当前版本。

同步脚本不会在这些情况中猜测用户意图。

## 规则来源

AgentMD 会阅读其他仓库中的规则，但只吸收适合本项目的部分。表格固定被审阅的 revision，并记录真正把建议写入 AgentMD 的提交。研究笔记保存在本地 `research/` 目录，不进入 Git，也不从 README 链接。

| 上游仓库 | 审阅 revision | 状态 | 对 AgentMD 的影响 | AgentMD 提交 |
| --- | --- | --- | --- | --- |
| [`lili-luo/aicoding-cookbook`](https://github.com/lili-luo/aicoding-cookbook) | [`0957cc4`](https://github.com/lili-luo/aicoding-cookbook/commit/0957cc4d767eb880675b487a918330e9ccde8edb) | 初始采用，后续重新整理 | 形成可观察失败、根因修复、结构性工作、有限计划和 Agent 执行规则的初稿 | [`f72b8db`](https://github.com/Woif-sha/AgentMD/commit/f72b8dbbe81054530dfec8e68fef11707176aa32) |
| [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills)（原 `forrestchang/andrej-karpathy-skills`） | [`2c60614`](https://github.com/multica-ai/andrej-karpathy-skills/commit/2c606141936f1eeef17fa3043a72095b4765b9c2) | 调整后采用 | 引入先思考、保持简单、限制改动范围和按目标验证四项原则 | [`b7e2d8c`](https://github.com/Woif-sha/AgentMD/commit/b7e2d8c0eb928b9e84e5ced95d5b5f24154a7492) |
| [`LB623/no-negative-echo`](https://github.com/LB623/no-negative-echo) | [`eba9f1d`](https://github.com/LB623/no-negative-echo/commit/eba9f1d2b4c19e699786a49427189988ad6d8d65) | 调整后采用 | 要求制品、提交、PR 和交接说明只描述最终接受的状态 | [`9f422e8`](https://github.com/Woif-sha/AgentMD/commit/9f422e8b5fe83b89773401cc1d0bcb808f1906e0) |
| [`lennney/stop-that-shit`](https://github.com/lennney/stop-that-shit) | [`68f4a7a`](https://github.com/lennney/stop-that-shit/commit/68f4a7a1303b00a8f8319eb33ff1ca84eb0ad3cc) | 调整后采用 | 明确回答、解释、审查、状态报告和诊断请求默认只读 | [`d56b7e1`](https://github.com/Woif-sha/AgentMD/commit/d56b7e1965afb60c0b7f05c5045afe9a663099fa) |
| [`conorbronsdon/avoid-ai-writing`](https://github.com/conorbronsdon/avoid-ai-writing) | [`58a95fc`](https://github.com/conorbronsdon/avoid-ai-writing/commit/58a95fc9971d7af95f1f1324b8a6bc991eb8004d) | 调整后采用 | 引入结论先行、信息密度、按内容组织和保留作者事实与声音边界的写作规则 | — |

只有在仓库证据能够确认来源时才登记。新的上游仓库进入考虑范围后，先记录审阅 revision；建议真正进入规则时，再补充对应的 AgentMD 提交。
