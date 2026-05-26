---
title: Prompt Bloat（提示词膨胀）
tags:
  - concept
  - prompt-bloat
  - context-management
  - llm
date: 2026-05-27
confidence: high
source: "[[sources/rag-mcp-mitigating-prompt-bloat]]"
aliases:
  - 提示词膨胀
  - 上下文膨胀
related:
  - "[[concepts/rag-mcp-framework]]"
  - "[[concepts/rag-for-tool-selection]]"
  - "[[concepts/model-context-protocol]]"
  - "[[papers/rag-mcp-2025]]"
status: growing
---

> **一句话定义**：Prompt Bloat 是指当 LLM 可用的外部工具或函数数量增长时，将所有工具描述放入 Prompt 导致的上下文窗口膨胀问题，表现为 Token 成本飙升、推理质量下降、选择准确率骤降。

## 核心要点

- **根本原因**：工具数量的线性增长导致 Prompt 大小的超线性增长，最终触碰上下文窗口上限
- **表现**：工具 < 10 时基本正常；10-50 时推理能力下降；> 100 时准确率骤降；> 1000 时基本不可用
- **影响**：不仅消耗 Token，更严重的是增加 LLM 的决策负担——模型需要从大量干扰项中筛选正确工具
- **缓解途径**：检索增强选择（如 RAG-MCP）、分层索引、自适应检索

## 详细解释

Prompt Bloat 是工具增强型 LLM 面临的核心可扩展性挑战。当 MCP 生态已有 4,400+ 服务器时，将所有工具的 Schema 描述放入 Prompt 已不现实：

1. **Token 成本**：每个工具的描述可能包含名称、参数 Schema、使用示例，累积起来轻松超过上下文窗口
2. **注意力稀释**：LLM 的注意力机制在处理大量无关工具描述时效率下降，类似 Needle-in-a-Haystack 问题——正确的工具被淹没在无关描述中
3. **幻觉风险**：模型在大量相似工具间混淆，甚至幻觉出不存在的 API

从认知角度类比，这类似于人类在过多选项中做选择时的"决策瘫痪"——选项越多，选择质量反而下降。

## 关系图谱

- **上游**：[[concepts/model-context-protocol|MCP]] — Prompt Bloat 在 MCP 工具集成场景下尤为突出
- **下游**：[[concepts/rag-mcp-framework|RAG-MCP 框架]] — 专门针对 Prompt Bloat 的解决方案
- **并列**：[[concepts/rag-for-tool-selection|RAG 工具选择]] — 缓解 Prompt Bloat 的核心方法
- **类比**：Needle-in-a-Haystack 测试 — 在大段上下文中检索单一事实的难度

## 来源

- [[sources/rag-mcp-mitigating-prompt-bloat|RAG-MCP 论文源文摘要]]
- [[papers/rag-mcp-2025|RAG-MCP 论文精读]]

## 思考与质疑

- 对话历史累积是否也会导致类似的"上下文膨胀"？这是否意味着 Prompt Bloat 也是长期 Agent 会话的一个问题？
- 当前的缓解方案聚焦于"减少输入"，是否也可以通过改进模型架构（如无限上下文窗口）从根源解决？
- **置信度评估**：有充分的实验数据支持（准确率从 13.62% 到 43.13% 的对比），置信度较高。但实验仅在 WebSearch 任务上验证，通用性待检验。
