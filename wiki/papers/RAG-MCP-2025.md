---
created: 2026-05-26
tags:
  - paper
  - RAG
  - MCP
  - tool-selection
  - prompt-bloat
related:
  - "[[RAG-MCP]]"
  - "[[RAG-for-Tool-Selection]]"
  - "[[MCP-Tool-Selection]]"
  - "[[Prompt-Bloat]]"
source: "https://arxiv.org/html/2505.03275v1"
---

# 论文精读：RAG-MCP — Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation

## 元信息

- **标题**：RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation
- **来源**：arXiv, 2025
- **链接**：https://arxiv.org/html/2505.03275v1
- **关键词**：Retrieval-Augmented Generation, Model Context Protocol, Tool Selection

## 问题背景

LLM 在集成大量外部工具（如 MCP 定义的函数）时面临两个核心问题：
1. **Prompt Bloat**：将所有工具描述放入 Prompt 会耗尽上下文窗口
2. **决策复杂度**：大量相似工具增加了 LLM 的选择错误率

## 方法

提出 **RAG-MCP**，将 RAG 思想应用于工具选择：
- 外部向量索引存储所有 MCP 工具的语义描述
- 用户查询到来时，检索器选取最相关的 Top-k 工具
- 仅将选中的工具描述注入 LLM Prompt

## 实验设计

1. **MCP Stress Test**：受 NIAH 启发，测试 N=1 到 11,100 时的工具选择准确率
2. **Baseline 对比**：
   - Blank Conditioning（全量注入）：13.62%
   - Actual Match（关键词匹配）：18.20%
   - **RAG-MCP**：**43.13%**

## 关键结论

- Prompt Token 减少 **50%+**
- 选择准确率提升 **3 倍以上**
- 新工具可动态加入索引，无需重训模型
- 在工具池规模较大时性能仍有下降空间，需要进一步优化

## 未来方向

- 分层检索（Hierarchical Indexing）
- 自适应检索策略（Adaptive Retrieval）
- 多工具工作流
- 真实环境 Agent 部署

## 相关笔记

- 框架概念：[[RAG-MCP]]
- RAG 应用：[[RAG-for-Tool-Selection]]
- MCP 挑战：[[MCP-Tool-Selection]]
- Prompt 膨胀：[[Prompt-Bloat]]
