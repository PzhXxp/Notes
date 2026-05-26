---
title: RAG 在工具选择中的应用
tags:
  - concept
  - rag
  - tool-selection
  - retrieval
date: 2026-05-27
confidence: high
source: "[[sources/rag-mcp-mitigating-prompt-bloat]]"
aliases:
  - 检索增强工具选择
  - tool retrieval
related:
  - "[[concepts/prompt-bloat]]"
  - "[[concepts/rag-mcp-framework]]"
  - "[[concepts/model-context-protocol]]"
  - "[[papers/rag-mcp-2025]]"
status: growing
---

> **一句话定义**：将检索增强生成（RAG）的思想从文档知识检索迁移到工具选择领域——不是检索文本段落来增强生成，而是检索工具 Schema 来增强函数调用。

## 核心要点

- **传统 RAG**：知识检索（文档段落）→ 增强生成
- **工具 RAG**：工具检索（API Schema）→ 增强工具调用
- **核心机制**：将所有工具的元数据编码为向量存入外部索引，用户查询到来时检索最相关的 Top-k 工具
- **关键优势**：无需重训模型、跨领域泛化、天然契合 MCP 的标准化 Schema

## 详细解释

### 范式迁移

RAG 在工具选择中的应用是对传统 RAG 范式的巧妙迁移：

| 维度 | 传统知识 RAG | 工具 RAG |
|------|-------------|---------|
| 检索目标 | 文档段落、事实 | API Schema、工具描述 |
| 增强对象 | LLM 生成回答 | LLM 函数调用 |
| 数据结构 | 非结构化文本 | 结构化 JSON Schema |
| 匹配方式 | 语义相似度 | 语义相似度 + 参数兼容性 |

### 工作机制

1. **索引阶段**：MCP 工具的 Schema（名称、描述、参数）被编码为向量，存入向量数据库
2. **检索阶段**：用户自然语言查询同样编码为向量，通过语义相似度匹配最相关工具
3. **注入阶段**：仅将 Top-1（或 Top-k）工具的 Schema 注入 LLM Prompt

### 与知识 RAG 的关键差异

工具 Schema 的结构化程度远高于普通文本（JSON Schema 定义了精确的参数类型和格式），这使得工具 RAG 在理论上可以实现比知识 RAG 更精确的匹配——不仅要找"相关"的工具，还要确保参数的兼容性。

## 关系图谱

- **上游问题**：[[concepts/prompt-bloat|Prompt Bloat]] — 工具 RAG 要解决的核心问题
- **下游实现**：[[concepts/rag-mcp-framework|RAG-MCP 框架]] — 工具 RAG 的具体架构实现
- **理论基础**：RAG（传统检索增强生成）— 同一范式的不同应用领域
- **协议基础**：[[concepts/model-context-protocol|MCP]] — 工具检索的标准化协议基础

## 来源

- [[sources/rag-mcp-mitigating-prompt-bloat|RAG-MCP 论文源文摘要]]

## 思考与质疑

- 工具检索的质量高度依赖工具描述的语义丰富度——描述太短或模糊，向量检索效果大打折扣
- 目前只检索单个最佳工具，真实场景可能需要多个工具的组合调用，需要更复杂的检索策略
- 检索延迟在工具数量极大时可能成为瓶颈（论文在 11,100 工具规模下已观察到退化），分层索引是潜在优化方向
