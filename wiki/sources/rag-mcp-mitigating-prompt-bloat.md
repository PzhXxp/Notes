---
title: "RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via RAG"
tags:
  - source
  - rag
  - mcp
  - prompt-bloat
  - tool-selection
date: 2026-05-27
confidence: high
source: "[[raw/RAG-MCP Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation.md|原始论文]]"
related:
  - "[[concepts/rag-mcp-framework]]"
  - "[[concepts/prompt-bloat]]"
  - "[[concepts/rag-for-tool-selection]]"
  - "[[concepts/model-context-protocol]]"
  - "[[papers/rag-mcp-2025]]"
status: evergreen
---

> **TL;DR**：本文提出 RAG-MCP 框架，将检索增强生成（RAG）与模型上下文协议（MCP）结合，通过语义检索动态选择最相关的工具描述注入 LLM，而非将所有工具描述塞入 Prompt。实验表明，该方法在工具选择准确率上提升 3 倍以上（43.13% vs 13.62% 基线），同时减少 50%+ 的 Prompt Token。

## 核心论点

1. **Prompt Bloat 是规模化工具集成的根本瓶颈**：当可用工具从几十增长到数千时，将所有工具描述放入 Prompt 的做法不可持续，会导致上下文窗口饱和、选择准确率骤降、Token 成本飙升
2. **检索增强工具选择**：将 RAG 的思想从知识检索迁移到工具检索——不是检索文档段落来增强知识，而是检索 API Schema 来增强函数调用
3. **解耦工具发现与 LLM 推理**：工具发现由外部检索器负责，LLM 只专注于使用已选工具执行任务——这是一种关注点分离（Separation of Concerns）的架构设计

## 关键引用

> "RAG-MCP uses semantic retrieval to identify the most relevant MCP(s) for a given query from an external index before engaging the LLM. Only the selected tool descriptions are passed to the model, drastically reducing prompt size and simplifying decision-making."

> "RAG-MCP significantly cuts prompt tokens (e.g., by over 50%) and more than triples tool selection accuracy (43.13% vs 13.62% baseline) on benchmark tasks."

> "Retrieval helps tame the growing toolset by providing the right tools at the right time, thereby reducing the model's decision burden."

## 提取的概念

- [[concepts/prompt-bloat|Prompt Bloat]] — 论文的核心问题域：工具描述过多导致的上下文膨胀
- [[concepts/rag-for-tool-selection|RAG 在工具选择中的应用]] — 核心方法论：将 RAG 从知识检索迁移到工具检索
- [[concepts/model-context-protocol|MCP（Model Context Protocol）]] — 协议基础：工具标准化与 Schema 定义
- [[concepts/rag-mcp-framework|RAG-MCP 框架]] — 论文提出的具体架构：三步流水线（检索→验证→调用）

## 我的思考

- RAG-MCP 的架构本质上是在 LLM 工具调用链中引入了一个**检索中介层**，这与传统软件架构中"服务发现/注册中心"的模式异曲同工
- 43.13% 的绝对准确率其实不算高——即使在检索辅助下，数千工具规模下的准确选择仍然困难。分层检索和自适应策略可能是必要的下一步
- 该方法强依赖工具描述的质量：若描述模糊或过时，语义检索效果直接下降。这要求 MCP 服务器维护者提供高质量的元数据
- RAG-MCP 的设计体现了一个重要的工程原则：**不要强迫 LLM 做它不擅长的事（从大量候选中筛选），而是用专门的系统（检索器）做擅长的事（语义匹配）**
