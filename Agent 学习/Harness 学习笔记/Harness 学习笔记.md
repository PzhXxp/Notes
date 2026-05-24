---
tags:
  - Agent
  - Harness
---
# 暂时的定义
Harness = Agent - Modal

Harness Engineering：
研究让大模型稳定运行的系统。

# 步骤：

## 上下文管理

### OpenAi 的方案

OpenAi 最开始设计了一个超大的 AGENT.md，里面包含所有需要用到的项目相关信息，随用户问题一起发给大模型。但是有以下问题：
1. [[Context 学习笔记#^efe0fa|内容也越多，效果越差]]。
2. 文件逐步腐化
	- 文件不会即使更新，内容会混乱到人都无法整理，ai 也无法判断有效内容。
3. 有效信息不一定在仓库中，可能是 Slack 或者其他文档中。
	- OpenAi 要求将所有项目相关信息其全部放到项目仓库中。


优化后的内容：
AGENT.md 只放目录，渐进式披露。

![[Pasted image 20260524200153.png]]

## 验证和反馈
### OpenAi 方案

通过 Tools 和 Skills 验证工具。

通过工具让 Ai 读取日志，指标，追踪链路。

![[Pasted image 20260524201723.png]]

### Anthropic 方案
Anthropic 使用的方案是用评估 Agent 进行对抗。也就是生成代码的 Agent 和评估 Agnet 拆开。

![[Pasted image 20260524205015.png]]


> [!quote]
> **Full Harness 方案**：
> Planner：需求分析
> Generator：代码生成
> Evaluator：验收

重要是每次只选择一个功能点，验收后再执行下一步。

![[Pasted image 20260524205200.png]]

模型更新能力增加后，去掉了每次一个的要求，Evaluator 只做最终验收。

![[Pasted image 20260524205447.png]]

## 技术债清理

Codex 任务进行中会产生很多垃圾内容。

![[Pasted image 20260524201903.png]]

设置一个后台的 Codex 任务，定期扫描代码库，找出其中不符合项目规范的自动修改并提交，已维护代码质量。

![[Pasted image 20260524201929.png]]

# 参考资料
- [Harness Engineering 到底是什么？概念、实战与争议，一次全部讲清楚](https://www.bilibili.com/video/BV12LR1B3EUt/?spm_id_from=333.1387.homepage.video_card.click&vd_source=785a544c73b4118d51145510c93b3cd2)
- OpenAI:
	- Harness engineering: leveraging Codex in an agent-first world https://openai.com/index/harness-engineering/ 
- Anthropic:
	- Effective harnesses for long-running agents https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents 
	- Harness design for long-running application development https://www.anthropic.com/engineering/harness-design-long-running-apps 
- LangChain
	- The Anatomy of an Agent Harness https://www.langchain.com/blog/the-anatomy-of-an-agent-harness 
- Mitchell Hashimoto:
	- My AI Adoption Journey https://mitchellh.com/writing/my-ai-adoption-journey
- martinfowler.com
	- Harness Engineering - first thoughts https://martinfowler.com/articles/exploring-gen-ai/harness-engineering-memo.html
	- Harness engineering for coding agent users https://martinfowler.com/articles/harness-engineering.html

---

[[Agent 学习目录]]
