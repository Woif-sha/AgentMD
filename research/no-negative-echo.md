# `no-negative-echo` 仓库调研

> 调研日期：2026-09-01
>
> 上游仓库：[`LB623/no-negative-echo`](https://github.com/LB623/no-negative-echo)
>
> 固定版本：[`eba9f1d2b4c19e699786a49427189988ad6d8d65`](https://github.com/LB623/no-negative-echo/commit/eba9f1d2b4c19e699786a49427189988ad6d8d65)
>
> 调研范围：README、Skill 运行时、扫描器、安装器、评测协议与用例、CI、提交历史、公开 issue/PR。仅使用仓库源码和 GitHub 官方页面等一手来源。

## 结论

这个仓库最值得借鉴的不是某个扫描脚本，而是一条清晰的交付原则：**从已接受、已验证的最终状态重新生成所有用户可见表面，让读者不需要知道工作会话；同时保留真实基线变化和安全、兼容、审计等必要事实。** Skill 将被否方案和用户纠正视为控制信息，而不是结果身份，并把标题、文件名、注释、commit、PR、caption、handoff 都纳入检查范围。[`SKILL.md` L8-L25](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L8-L25)

对 AgentMD，最合适的做法是吸收一条短小的全局“最终状态叙事”规则，并在现有 Git 交付规则中补足“文案来自 task-owned diff 和实际 read-back 状态”。当前不值得复制整套安装器、扫描器或高保障流程：AgentMD 是通过 Git 与符号链接维护的指令仓库，不是需要多宿主分发的独立 Skill 包；而且上游自己的 issue 已证明，把高保障审计放进默认路径会造成明显的上下文与时间浪费。[Issue #6](https://github.com/LB623/no-negative-echo/issues/6)及其[维护者回复](https://github.com/LB623/no-negative-echo/issues/6#issuecomment-5472905997)

## 它在解决什么

目标故障不是一般意义上的“否定句太多”，而是**会话历史泄漏到成品**：方案已被否决或措辞已被纠正，最终标题、代码注释、commit、PR 或交付说明却继续以“没有 X”“移除 X”“为什么不用 X”为中心。README 将其定义为从最终状态重新生成交付文案，并检查多个交付面，而不只是正文。[`README.md` L22-L37](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/README.md#L22-L37)

它刻意把以下两类信息分开：

- **会话残留**：只在讨论中出现、从未进入权威基线的备选方案；助手草稿、中间尝试、用户的措辞纠正。这些通常应省略。
- **交付事实**：已发布 API 的真实删除、迁移、已执行外部操作，以及安全、法律、兼容、审计、引用或用户要求的比较。这些必须按受众需要保留。

上游 README 给出了明确分类表和三个逐表面判断问题；核心不是匹配否定词，而是判断无会话历史的读者是否需要、遗漏是否造成风险，以及它是否属于真实基线变化。[`README.md` L101-L118](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/README.md#L101-L118)

## 核心机制与设计原则

### 1. 从正向目标重生，而不是在被否文案上修补

Skill 要求从 positive target 和 observed final state 生成每个表面；若标题、开篇、标签或文件名的框架来自被否方案，就整体重写，而不是把原句改成近义词、委婉语或“合规版”标签。[`SKILL.md` L21-L31](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L21-L31)

这是比“禁止若干词”更深的原则：逐词删改仍然会保留被否方案的语义框架；从最终状态重生，才能把内容重心拉回实际成果。

### 2. 每个交付面独立判断

同一事实可能应该出现在迁移说明里，却不应出现在新 API 名称、标题或普通 handoff 中。Skill 因此显式枚举标题、文件名、注释、commit、PR、caption、handoff，并要求分别验证直接引用、语义改写和任务事实是否丢失。[`SKILL.md` L12-L19](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L12-L19)、[`SKILL.md` L33-L44](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L33-L44)

### 3. 以权威基线区分“真实变化”和“会话尝试”

高保障规则把 merge-base/已提交状态、已发布产品或用户确认稿作为权威基线；助手草稿和临时编辑属于会话历史，但已经执行的发送、发布、上传、删除、迁移和部分失败属于审计事实，即使后来回滚也不能抹掉。[`high-assurance-finalization.md` L7-L17](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/references/high-assurance-finalization.md#L7-L17)

这条边界防止规则走向另一个极端：为了“无残留”而删除必要 API 名、诊断、测试、快照或用户已有改动。核心 Skill 也明确要求保留这些内容。[`SKILL.md` L23-L25](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L23-L25)

### 4. 交付后读回，而不是相信将要发生的状态

常规流程要求：任何工具、hook 或外部系统改变用户可见表面后，都要读取实际结果并重新检查。[`SKILL.md` L42-L44](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L42-L44) 高保障流程进一步明确为 preflight → frozen mutation → readback → postflight，后来任何改动都会使此前检查失效。[`high-assurance-finalization.md` L32-L39](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/references/high-assurance-finalization.md#L32-L39)

### 5. 常规路径短，高风险流程按需加载

当前核心 `SKILL.md` 只有 48 行；敏感信息、公开或难以回退的变更、长/压缩上下文、委派和严格审计才加载高保障参考文件。[`SKILL.md` L46-L48](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L46-L48) 高保障模式才引入清洗后的生产规格、上下文隔离和独立验证。[`high-assurance-finalization.md` L19-L30](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/references/high-assurance-finalization.md#L19-L30)

这个分层结构与 AgentMD 已有的“全局不变量 + 条件规则”架构一致，值得直接沿用。

## 工程实现中值得学习的地方

### 扫描器：只承担确定性、有限的职责

`check_surface.py` 对关键词做 NFKC + casefold 归一化，并同时检查文本内容与文件名/根相对路径；输出只包含文件序号、命中数量和表面类型，不回显被扫描词。[`check_surface.py` L44-L55](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/scripts/check_surface.py#L44-L55)、[`check_surface.py` L273-L323](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/scripts/check_surface.py#L273-L323)

它还把双向控制符和部分默认可忽略 Unicode 字符标为 `REVIEW`，并拒绝不安全路径结构。[`check_surface.py` L141-L164](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/scripts/check_surface.py#L141-L164)、[`check_surface.py` L191-L212](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/scripts/check_surface.py#L191-L212)

可借鉴的是**让自动化只做它能证明的事**。README 明确说明扫描器不能发现语义改写，`PASS` 也不是语义合规证明；凭据、隐私和合规仍应交给专用工具。[`README.md` L121-L130](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/README.md#L121-L130)

### 评测：同时衡量“去残留”和“保任务”

评测不是只数禁词，而是把 residue control 与 task preservation 作为共同主要结果，并将 Skill 路由单独报告。[`evaluation-protocol.md` L129-L138](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L129-L138) 用例既包含应省略的会话备选项，也包含必须保留的真实删除、安全排除、比较、兼容和领域否定规则。[`evaluation-cases.md` L24-L86](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/tests/evaluation-cases.md#L24-L86)

它还设计了 `no-skill`、固定 comparator、显式调用和隐式调用四个条件，并用相同最终规格的一对对话比较“干净会话”和“注入被否备选项的会话”。[`evaluation-protocol.md` L53-L77](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L53-L77)

更严格的部分包括隔离 producer、冻结 manifest、双盲评审、独立 adjudicator、可信 collector 和输出哈希绑定。[`evaluation-protocol.md` L15-L51](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L15-L51) 这些方法适合未来真正评测 AgentMD 规则是否改变模型行为，但不应在没有行为回归问题时一次性全部引入。

### 包边界：运行时与评测素材分离

仓库把可安装 Skill 限定为 `no-negative-echo/`，并测试运行时包不包含 oracle、评测 prompt、评分器或测试文件，从而减少上下文污染和被测对象读取答案的风险。[`test_scripts.py` L417-L431](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/tests/test_scripts.py#L417-L431)

这个“运行时规则与开发/评测材料分离”的原则适合 AgentMD：全局加载文件应短，解释、案例和评测资产留在条件文档或仓库级材料中。

## 对 AgentMD 的具体借鉴建议

| 优先级 | 建议 | 与当前仓库的关系 |
| --- | --- | --- |
| 高 | 在 `global/AGENTS.md` 增加一个短小的“最终状态叙事”不变量：最终产物及其标题、文件名、注释、commit、PR 和 handoff 面向没有会话历史的读者，只描述最终采用状态；会话中的被否方案和中间尝试仅在安全、准确、兼容、审计、迁移、引用、比较或真实基线变化需要时出现。 | 现有 “Surgical Changes” 约束改动范围，但尚未直接覆盖交付文案中的会话残留。 |
| 高 | 在 `global/rules/git-delivery.md` 中补一句：commit/PR/交付说明从 task-owned diff 和实际 read-back 状态生成，不把临时尝试或无关用户改动写进叙事。 | 现有规则已要求只 stage 本任务文件、保留用户改动和确认最终状态；这是对“文案来源”的窄补充。 |
| 中 | 把“工具/hook/远端改变表面后重新读回”作为 Git/发布路径的明确不变量。 | 当前规则已有提交、推送和状态确认，可用一句话明确 handoff 也必须基于读回事实。 |
| 中 | 若以后对全局规则做行为评测，至少使用正例/反例成对用例，并同时检查“目标残留是否消失”和“必要事实是否仍在”。 | 可先从少量 Markdown fixture 开始，不必照搬完整盲评与证据哈希体系。 |
| 低 | 只有在多次出现稳定、非敏感的关键词残留时，才引入可选扫描脚本。 | 当前没有证据表明 AgentMD 需要一套新扫描器；语义判断仍是主路径。 |

建议的最小规则草案如下，供后续修改任务参考，不在本次只读调研中直接应用：

```markdown
## Final-State Communication

- Generate user-visible artifacts and delivery metadata from the accepted final state for a reader without session history.
- Omit rejected session-only alternatives and intermediate attempts unless they are required for safety, accuracy, compatibility, audit, migration, quotation, comparison, or a real baseline change.
- Re-read surfaces changed by tools, hooks, or external systems, and base the final handoff on the observed result.
```

## 不建议直接照搬的部分

### 1. 不要把高保障流程变成默认流程

上游 #6 的安装者反馈显示，旧版安装说明诱导 Agent 审查全部 Python、跑完整测试并枚举无关 Skill/package，消耗约 100k 上下文。[Issue #6](https://github.com/LB623/no-negative-echo/issues/6) 维护者随后在 PR #7 中把完整源码审计和测试保留为显式高保障步骤，默认安装委托给安装器内部完成，并删除了 277 行安装说明。[PR #7](https://github.com/LB623/no-negative-echo/pull/7) 当前安装合约也明确禁止重复读取全部 Python、运行完整测试或枚举无关包。[`INSTALL.md` L47-L76](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/INSTALL.md#L47-L76)

这正好印证 AgentMD 的 scope discipline：默认路径只解决当前 live uncertainty，高保障审计按风险或明确请求触发。

### 2. 不要为 AgentMD 复制安装器与 provenance 系统

上游安装器维护固定运行时清单、多个宿主目录、provenance 哈希、未知文件拒绝、staging、锁、升级与回滚；这些服务于“从不可信临时 clone 安装到多个用户级 Skill 根”的分发场景。[`install_skill.py` L20-L68](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/scripts/install_skill.py#L20-L68)、[`install_skill.py` L590-L674](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/scripts/install_skill.py#L590-L674)

AgentMD 已以 Git 仓库作为单一真源，并通过仓库脚本管理同机符号链接。除非未来要发布独立 Skill 包，否则复制这套机制只会建立第二套分发与完整性模型。

### 3. 不要把关键词扫描当作语义验收

扫描器只能发现已知字面量、路径和部分 Unicode 混淆；换成近义词或“已符合要求”式自证仍可能漏过。上游自己明确拒绝把零命中当作语义证明。[`SKILL.md` L35-L44](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/SKILL.md#L35-L44) 对敏感值，甚至不应把原文写入扫描命令或 terms file，而应使用受信任的 secret/DLP 工具。[`high-assurance-finalization.md` L13-L17](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/references/high-assurance-finalization.md#L13-L17)

## 局限与风险

1. **没有公开的模型行为效果结论。** 仓库提供了严谨协议和确定性评分器测试，但 README 明确说 CI 不代表模型行为有效性；协议也强调安装、发现和单条件 `PASS` 都不能证明普遍效果。[`README.md` L132-L138](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/README.md#L132-L138)、[`evaluation-protocol.md` L3-L13](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L3-L13)
2. **它是提示词缓解，不是信息流隔离。** Skill 不能清除模型已读上下文、强制宿主激活，也不能控制工具日志、审批提示和宿主 UI。[`high-assurance-finalization.md` L5-L9](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/no-negative-echo/references/high-assurance-finalization.md#L5-L9)
3. **隐式路由存在不确定性。** `allow_implicit_invocation` 只允许路由，不证明 Skill 实际激活；上游协议要求独立 host trace 才能判定 activation。[`evaluation-protocol.md` L62-L64](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L62-L64)、[`evaluation-protocol.md` L121-L127](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/evals/evaluation-protocol.md#L121-L127) 对 AgentMD 而言，把核心行为放在始终加载的 `global/AGENTS.md` 比依赖隐式 Skill 路由更稳妥。
4. **过度清理可能损害事实完整性。** 如果把所有否定、删除或旧名称都当作残留，会破坏迁移、安全、兼容和审计说明。上游用正反用例和 task-preservation 指标抵消这个风险；AgentMD 若吸收规则，也必须保留同样的例外边界。
5. **工程体量与问题本身不成比例。** 核心行为规则很短，但分发安装器和测试占据仓库绝大部分代码。其工程质量可以学习，体量不适合直接迁移到当前以 Markdown 指令为主的 AgentMD。

## 验证记录

- 在临时目录完整克隆上游仓库并固定到 `eba9f1d2b4c19e699786a49427189988ad6d8d65`。
- 本地运行 `python -I -m unittest discover -s tests -p "test_*.py" -v`：`Ran 114 tests`，`OK (skipped=8)`。
- GitHub 在该 commit 上的官方 `test` workflow 为成功状态，覆盖 Ubuntu/Python 3.10、Ubuntu/Python 3.13、macOS/Python 3.11 和 Windows/Python 3.11。[workflow 定义](https://github.com/LB623/no-negative-echo/blob/eba9f1d2b4c19e699786a49427189988ad6d8d65/.github/workflows/test.yml#L14-L38)、[Actions run](https://github.com/LB623/no-negative-echo/actions/runs/33350389193)
- 上述测试只验证安装器、扫描器、评测评分器和 fixture 契约；不把它表述为 Skill 的模型行为效果证明。
