---
tags:
  - Agent
  - Context
---

> [!info]
> 名词：
> Context：模型输入
> Context Window：模型输入容量上下文
> Context Engineering：上下文工程，是设计给模型的输入内容


# 问题

## 太长的上下文可能导致以下问题：
- [语境中毒：语境中毒是指幻觉或其他错误进入语境，并在语境中被反复提及。_](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html?ref=blog.langchain.com#context-poisoning)
- [情境干扰：上下文干扰是指上下文发展到一定程度，导致模型过度关注上下文，而忽略了训练期间学到的内容。](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html?ref=blog.langchain.com#context-distraction)
- [语境混淆：上下文混淆是指模型使用上下文中的冗余内容来生成低质量的响应。](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html?ref=blog.langchain.com#context-confusion)
- [语境冲突：上下文冲突是指你在你的环境中积累了新的信息和工具，而这些信息和工具与环境中的其他信息相冲突。这是"语境混淆"的一个更严重的版本](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html?ref=blog.langchain.com#context-clash)

更大的上下文会产生新的失效模式。
上下文污染会嵌入错误，这些错误会随着时间的推移而累积。
上下文干扰会导致用户过度依赖上下文，重复过去的操作，而不是向前迈进。
上下文混乱会导致使用不相关的工具或文档。
上下文冲突会造成内部矛盾，从而阻碍推理。

> [!quote]
> ## 情境管理策略
> - [**RAG：**选择性地添加相关信息，以帮助LLM生成更好的响应](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#rag)
> - [**工具加载：**仅选择相关的工具定义添加到您的上下文中](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#tool-loadout)
> - [**上下文隔离：**将上下文隔离到各自独立的线程中](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#context-quarantine)
> - [**上下文修剪：**从上下文中移除不相关或不需要的信息](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#context-pruning)
> - [**上下文概括：**将积累的上下文信息提炼成简洁的摘要](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#context-summarization)
> - [**上下文卸载：**将信息存储在LLM上下文之外，通常是通过存储和管理数据的工具来实现。](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html#context-offloading)

## 日常开发需要注意：
1. 如果其上下文中的“目标”部分被污染，则智能体将制定无意义的策略并重复行为以追求无法实现的目标。
2. 累积的上下文可能会变得分散注意力。
3. 当提供多个工具时，_所有模型的性能都会下降_。问题在于：如果你把某些信息放入上下文中，_模型就必须关注它_。这些信息可能无关紧要，也可能是不必要的工具定义，但模型_都会将_其考虑在内。
4. 分片提示会导致结果变差。原因就是“上下文混淆”：
包含完整聊天记录的上下文中包含了模型 _在掌握所有信息之前_ 尝试回答问题的早期结果。这些错误答案会保留在上下文中，并在模型生成最终答案时对其产生影响

# Context Engineering 实现方式
![[Pasted image 20260524161738.png]]

## 保存 Context
对 Context 做筛选/总结，然后保存到某个位置，在模型需要的时候发给模型，解决信息持久化的问题。【memory】

## 选择 Context
从海量信息中选择出于用户相关的内容人。
### 静态选择
把必须遵守的信息，在每次请求的时候，都放到 context 中（System Prompt、Rules、CLAUDE.md)
### 动态选择
选择与用户问题最相关的内容放入 Context 中。例如 chatGPT 挑选记忆，或者挑选工具放进 Context。【RAG】

## 压缩 Context
Context 最占空间的两类数据：模型输出文本，工具执行结果。一般会压缩历史消息。一般压缩会总结之前的内容，然后把之前的内容扔掉。

![[Pasted image 20260524144049.png|336]]

## 隔离 Context

各个 Agent 有独立的 Context，避免互相干扰。

![[Pasted image 20260524160011.png|398]]

# 进阶学习参考
- https://blog.langchain.com/context-engineering-for-agents 
- https://cognition.ai/blog/dont-build-multi-agents
- [# How Long Contexts Fail ](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html?ref=blog.langchain.com#context-poisoning)
- [How to Fix Your Context](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html)

***

[[Agent 学习目录]]