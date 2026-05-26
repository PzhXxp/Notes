---
title: MCP（Model Context Protocol）
tags:
  - concept
  - mcp
  - function-calling
  - protocol
date: 2026-05-27
confidence: high
source: "[[sources/rag-mcp-mitigating-prompt-bloat]]"
aliases:
  - 模型上下文协议
  - Model Context Protocol
related:
  - "[[concepts/rag-mcp-framework]]"
  - "[[concepts/prompt-bloat]]"
  - "[[concepts/rag-for-tool-selection]]"
  - "[[papers/rag-mcp-2025]]"
status: growing
---

> **一句话定义**：MCP（Model Context Protocol）是 Anthropic 推出的开放标准协议，定义了 AI 系统与外部数据源和服务之间的统一连接方式，取代碎片化的单点集成方案。

## 核心要点

- **定位**：AI 领域的"USB-C 接口"——一个通用标准替代各种专有集成
- **规模**：截至 2025 年 4 月，公共 MCP 仓库已有 4,400+ 服务器（mcp.so）
- **标准化内容**：统一了工具 Schema 格式（名称、参数、认证），使工具发现和调用规范化
- **衍生挑战**：工具数量激增带来 Prompt Bloat 和选择复杂度问题——这是成功的代价

## 详细解释

MCP 是 LLM 工具调用生态的基础设施层。它定义了一套标准化的接口规范，让任何 MCP 服务器都能以统一的方式与 LLM 客户端交互。

### 核心组件

- **MCP Server**：提供具体工具功能的服务器，暴露标准化的 Schema 接口
- **MCP Schema**：包含工具名称、参数定义、用途描述、认证信息等元数据
- **MCP Client**：LLM 或 AI 应用，通过 MCP 协议发现和调用工具

### 生态悖论

MCP 的易用性和标准化带来了成功的悖论：工具越多 → 集成越丰富 → Prompt 越臃肿 → 选择越困难。这正是 [[concepts/prompt-bloat|Prompt Bloat]] 问题的根源，也是 [[concepts/rag-mcp-framework|RAG-MCP]] 要解决的核心矛盾。

## 关系图谱

- **基础设施**：MCP 是所有上层方案的基础协议
- **衍生问题**：[[concepts/prompt-bloat|Prompt Bloat]] — MCP 生态扩大后直接导致的问题
- **衍生方案**：[[concepts/rag-mcp-framework|RAG-MCP 框架]] — 基于 MCP 的检索增强解决方案
- **相关方法**：[[concepts/rag-for-tool-selection|RAG 工具选择]] — 解决 MCP 规模问题的核心方法

## 来源

- [[sources/rag-mcp-mitigating-prompt-bloat|RAG-MCP 论文源文摘要]]
- [Anthropic MCP 官方公告](https://www.anthropic.com/news/model-context-protocol)

## 思考与质疑

- MCP 的标准化是一把双刃剑：降低了集成门槛，也导致了工具数量的失控增长
- 生态达到 4,400+ 规模后，"工具发现"本身成为核心问题，催生了检索层的需求
- 未来 MCP 协议本身可能需要内置检索/发现机制，而非完全依赖外部框架
