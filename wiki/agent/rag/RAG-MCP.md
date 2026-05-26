---
created: 2026-05-26
tags:
  - RAG
  - MCP
  - tool-selection
  - agent
related:
  - "[[RAG-for-Tool-Selection]]"
  - "[[MCP-Tool-Selection]]"
  - "[[Prompt-Bloat]]"
  - "[[RAG-MCP-2025]]"
source: "https://arxiv.org/html/2505.03275v1"
---

# RAG-MCP 框架

## 概述

**RAG-MCP**（Retrieval-Augmented Generation + Model Context Protocol）是一个将检索增强生成与模型上下文协议相结合的框架，旨在解决 LLM 在大量外部工具中选择正确工具时的可扩展性问题。

核心思路：**摒弃将所有工具描述塞入 Prompt 的做法，改为在调用 LLM 之前通过语义检索动态获取最相关的工具描述。**

## 核心 Pipeline

RAG-MCP 的工作流程分为三个步骤：

1. **Retrieval（检索）**：将用户任务描述编码为向量，在 MCP 工具索引中执行语义检索，返回 Top-k 候选工具
2. **Validation（验证）**：对每个检索到的 MCP 生成 few-shot 示例查询进行兼容性检查（"合理性检查"）
3. **Invocation（调用）**：仅将最匹配的单个 MCP 描述注入 LLM Prompt，由 LLM 执行计划与调用

## 关键实验结果

| 方法 | 准确率 | 平均 Prompt Token |
|-----|--------|-----------------|
| **RAG-MCP** | **43.13%** | **1,084** |
| Actual Match（关键词匹配） | 18.20% | 1,646 |
| Blank（全量注入） | 13.62% | 2,134 |

- 准确率比全量注入提升 **3 倍以上**
- Prompt Token 减少 **50%+**
- 实验中工具池规模从 1 到 11,100 个 MCP 不等

## 核心优势

- **缓解 Prompt Bloat**：只注入相关工具描述，避免上下文窗口被无关信息填满
- **降低决策负担**：LLM 无需从数百个工具中筛选，减少幻觉和误选
- **资源效率**：按需激活 MCP 服务器，避免启动时实例化所有工具
- **可扩展性**：新工具只需索引其元数据，无需重训模型
- **多轮鲁棒性**：对话中无需重复携带所有工具描述，检索器动态处理

## 参考

- 原始论文：[[RAG-MCP-2025]]
- 相关概念：[[RAG-for-Tool-Selection]] | [[MCP-Tool-Selection]] | [[Prompt-Bloat]]
