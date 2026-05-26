---
title: RAG-MCP 框架
tags:
  - concept
  - rag-mcp
  - rag
  - mcp
  - tool-selection
date: 2026-05-27
confidence: high
source: "[[sources/rag-mcp-mitigating-prompt-bloat]]"
aliases:
  - RAG-MCP
related:
  - "[[concepts/prompt-bloat]]"
  - "[[concepts/rag-for-tool-selection]]"
  - "[[concepts/model-context-protocol]]"
  - "[[papers/rag-mcp-2025]]"
status: growing
---

> **一句话定义**：RAG-MCP 是一个将检索增强生成与模型上下文协议相结合的框架，通过在 LLM 调用之前引入语义检索步骤，从大量工具中动态选择最相关的工具描述，从而解决 Prompt Bloat 问题。

## 核心要点

- **核心创新**：将工具发现与 LLM 生成解耦，引入外部检索中介层
- **三步流水线**：Retrieval（检索）→ Validation（验证）→ Invocation（调用）
- **性能提升**：准确率 43.13%（vs 全量注入 13.62%），Token 减少 50%+
- **可扩展性**：新工具只需加入索引，无需重训模型

## 详细解释

RAG-MCP 解决的是一个直观但重要的问题：当 LLM 有太多工具可用时，如何帮它选出正确的那个？

### 工作流程

```
用户查询 → 编码为向量
                ↓
     [外部向量索引: 4,400+ MCP Schema]
                ↓ (语义检索 Top-k)
      候选工具 → 验证(合理性检查)
                ↓
     LLM 收到: 仅最匹配的单个工具 Schema
                ↓
     LLM 执行: 计划 + 调用
```

### 三步流水线详解

1. **Retrieval（检索）**：使用 Qwen-max 将用户任务编码为向量，在 MCP Schema 索引中执行语义检索，返回 Top-k 候选工具
2. **Validation（验证）**：对检索到的每个 MCP 生成 few-shot 示例查询，测试其响应以进行"合理性检查"，确保工具确实可用且参数兼容
3. **Invocation（调用）**：仅将最匹配的单个 MCP Schema 注入 LLM Prompt，LLM 在此基础上执行计划与调用

### MCP Stress Test

论文设计了受 Needle-in-a-Haystack 启发的压力测试——将候选工具从 1 扩展到 11,100 个，测量选择准确率的变化：

- 工具池 < 30：准确率 > 90%（基本可用）
- 工具池 30-70：准确率开始波动
- 工具池 > 100：准确率大幅退化
- RAG-MCP 在所有规模下均显著优于基线

## 关键实验结果

| 方法 | 准确率 | 平均 Prompt Token |
|------|--------|-------------------|
| **RAG-MCP** | **43.13%** | **1,084** |
| Actual Match（关键词匹配） | 18.20% | 1,646 |
| Blank（全量注入） | 13.62% | 2,134 |

## 核心优势

- **缓解 Prompt Bloat**：只注入相关工具描述，避免上下文窗口被无关信息填满
- **降低决策负担**：LLM 无需从数百个工具中筛选，减少幻觉和误选
- **资源效率**：按需激活 MCP 服务器，避免启动时实例化所有工具
- **可扩展性**：新工具只需索引其元数据，无需重训模型
- **多轮鲁棒性**：对话中无需重复携带所有工具描述，检索器动态处理

## 关系图谱

- **解决的问题**：[[concepts/prompt-bloat|Prompt Bloat]]
- **检索方法**：[[concepts/rag-for-tool-selection|RAG 在工具选择中的应用]]
- **基础协议**：[[concepts/model-context-protocol|MCP]]
- **论文详情**：[[papers/rag-mcp-2025|RAG-MCP 论文精读]]

## 来源

- [[sources/rag-mcp-mitigating-prompt-bloat|RAG-MCP 论文源文摘要]]
- [[papers/rag-mcp-2025|RAG-MCP 论文精读]]

## 思考与质疑

- 43.13% 的准确率远超基线（13.62%），但绝对数字仍有很大提升空间——过半场景中 LLM 仍然选错工具
- 当前只支持单工具调用，真实 Agent 场景通常需要多工具协作（论文明确承认此局限）
- 检索器的选择（Qwen-max）对整体性能有决定性影响——RAG-MCP 的上限取决于检索质量，而非 LLM 本身
