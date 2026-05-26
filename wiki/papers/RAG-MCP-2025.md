---
title: "RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via RAG"
tags:
  - paper
  - rag
  - mcp
  - tool-selection
  - prompt-bloat
date: 2026-05-27
confidence: high
source: "[[sources/rag-mcp-mitigating-prompt-bloat]]"
aliases:
  - RAG-MCP 论文
related:
  - "[[concepts/rag-mcp-framework]]"
  - "[[concepts/prompt-bloat]]"
  - "[[concepts/rag-for-tool-selection]]"
  - "[[concepts/model-context-protocol]]"
status: evergreen
---

> **问题**：LLM 在集成大量外部工具时，将所有工具描述放入 Prompt 会导致 Prompt Bloat 和选择准确率下降，如何可扩展地解决这一问题？
>
> **方法**：提出 RAG-MCP，通过语义检索从外部索引中动态选择最相关的工具描述注入 LLM，将工具发现与 LLM 推理解耦。
>
> **结论**：RAG-MCP 在工具选择准确率上提升 3 倍（43.13% vs 13.62%），Prompt Token 减少 50%+。

## 元信息

- **标题**：RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation
- **来源**：arXiv, 2025
- **链接**：https://arxiv.org/html/2505.03275v1
- **关键词**：Retrieval-Augmented Generation, Model Context Protocol, Tool Selection, Prompt Bloat
- **致谢**：基于 Zhiling Luo, Xiaorong Shi 等人的 MCP 服务器评估报告

## 背景与动机

LLM 的工具调用正从少量精选 API 扩展到数千个 MCP 服务器，带来两个核心问题：

1. **Prompt Bloat**：将所有工具描述放入 Prompt 会快速耗尽上下文窗口，模型的有效推理空间被挤占
2. **决策复杂度**：大量相似工具增加选择错误率，模型在相似 API 间混淆，甚至幻觉出不存在的函数

现有方法（Toolformer、ReAct、WebGPT）均在小规模工具集（< 20 个）上验证，未解决大规模场景下的可扩展性问题。

## 方法详解

RAG-MCP 将 RAG 原则应用于工具选择，核心是**解耦工具发现与 LLM 推理**：

1. **外部向量索引**：所有 MCP 工具的 Schema（名称、描述、参数）预编码为向量存储
2. **语义检索**：用户查询编码后在索引中检索 Top-k 候选工具
3. **验证**：对候选工具进行合理性检查（生成 few-shot 示例并测试响应）
4. **注入执行**：仅将最优工具的 Schema 注入 LLM Prompt 用于执行

## 实验设计

| 维度 | 细节 |
|------|-------|
| 基准 LLM | Qwen-max-0125 |
| 自动评估 | Deepseek-v3 |
| 验证任务 | MCPBench WebSearch 子集（20 个任务 x 20 轮） |
| 工具规模 | N=1 到 11,100 个 MCP（26 个区间） |
| 基线对比 | Blank Conditioning（全量）、Actual Match（关键词匹配） |

### MCP Stress Test

受 Needle-in-a-Haystack 测试启发，将正确的 MCP 工具（Needle）混入大量无关工具（Haystack），测试不同规模下的选择准确率。

## 实验结果

| 方法 | 准确率 | 平均 Prompt Token | 平均 Completion Token |
|------|--------|-------------------|----------------------|
| **RAG-MCP** | **43.13%** | **1,084** | 78.14 |
| Actual Match | 18.20% | 1,646 | 23.60 |
| Blank | 13.62% | 2,134 | 162.25 |

**关键发现**：
- 工具池 < 30：准确率 > 90%
- 工具池 30-70：开始波动
- 工具池 > 100：大幅退化
- RAG-MCP 在所有规模下均显著优于基线
- RAG-MCP 的 Completion Token 略高（78 vs 24），反映更充分的推理过程

## 局限性

- **绝对准确率低**：43.13% 意味过半场景选错工具，仍有巨大改进空间
- **单工具限制**：仅支持每次调用选择单个工具，不支持多工具工作流
- **检索瓶颈**：检索器质量直接决定整体性能
- **规模退化**：工具池极大时（> 1,000）检索精度下降

## 未来方向

- 分层检索（Hierarchical Indexing）
- 自适应检索策略（Adaptive Retrieval）
- 多工具工作流支持
- 真实环境 Agent 部署验证

## 相关笔记

- [[concepts/rag-mcp-framework|RAG-MCP 框架]] — 论文提出的具体架构
- [[concepts/prompt-bloat|Prompt Bloat]] — 论文解决的核心问题
- [[concepts/rag-for-tool-selection|RAG 工具选择]] — 论文的核心方法论
- [[concepts/model-context-protocol|MCP]] — 论文的协议基础
