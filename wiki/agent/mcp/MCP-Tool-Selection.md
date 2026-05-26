---
created: 2026-05-26
tags:
  - MCP
  - tool-selection
  - function-calling
  - agent
related:
  - "[[RAG-MCP]]"
  - "[[Prompt-Bloat]]"
  - "[[RAG-for-Tool-Selection]]"
source: "https://arxiv.org/html/2505.03275v1"
---

# MCP 工具选择挑战

## 背景

MCP（Model Context Protocol）定义了一套通用标准，让 AI 系统与外部数据源和服务连接。截至 2025 年 4 月，公共 MCP 仓库已有 **4,400+ 服务器**。

## 核心问题：工具选择的可扩展性

当 LLM 需要从大量 MCP 工具中选择正确的那个时，面临两个关键挑战：

### 1. Prompt Bloat
每个 MCP 都有其 schema 描述（名称、参数、用途描述）。将所有工具的描述都放入 Prompt 会消耗大量 Token，甚至超出上下文窗口限制。

### 2. 决策复杂度
- 工具数量越多，LLM 的选择错误率越高
- 相似功能的工具之间细微差别容易被忽略
- 模型可能幻觉出不存在的 API 或选错库

> **案例**：实验中，当 MCP 池从 1 个扩展到 100+ 个时，LLM 的裸工具选择准确率从 90%+ 骤降至 20% 以下。

## RAG-MCP 的解决方案

RAG-MCP 通过将工具发现与 LLM 生成解耦来解决这个问题：

1. 各 MCP 工具的 schema 事先索引到外部向量数据库
2. 用户请求到来时，检索器从索引中选出最相关的工具
3. LLM 只看到被选中的工具描述，无需处理大量干扰项

### MCP Stress Test

受 Needle-in-a-Haystack 测试启发，论文设计了 MCP 压力测试：
- 改变候选 MCP 数量 N（从 1 到 11,100）
- 评估 LLM 在不同规模工具池下的选择准确率
- 量化 Prompt Bloat 对工具选择的影响

## 参考

- 解决方案框架：[[RAG-MCP]]
- 核心概念：[[Prompt-Bloat]]
- RAG 的应用：[[RAG-for-Tool-Selection]]
