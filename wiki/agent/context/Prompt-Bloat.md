---
created: 2026-05-26
tags:
  - prompt-bloat
  - context-management
  - prompt-engineering
  - agent
related:
  - "[[RAG-MCP]]"
  - "[[MCP-Tool-Selection]]"
  - "[[RAG-for-Tool-Selection]]"
source: "https://arxiv.org/html/2505.03275v1"
---

# Prompt Bloat（提示词膨胀）

## 定义

**Prompt Bloat** 是指当 LLM 可用的外部工具/函数数量增加时，将所有工具描述放入 Prompt 导致的上下文窗口膨胀问题。

这不仅消耗大量 Token，还降低了 LLM 的处理能力——模型需要从大量干扰项中识别正确的工具。

## 表现

| 工具数量 | 典型问题 |
|----------|---------|
| 少量（<10） | 可以正常工作 |
| 中等（10-50） | Prompt 空间被工具描述占用，推理能力下降 |
| 大量（>100） | Token 成本飙升，选择准确率骤降 |
| 极大量（1000+） | 可能超出上下文限制，基本不可用 |

## MCP Stress Test

论文提出了受 **Needle-in-a-Haystack（NIAH）** 测试启发的评估方法：

- 将正确的 MCP 工具（"Needle"）混入大量无关工具（"Haystack"）
- 测试 LLM 从不同规模的工具池中选出正确工具的能力
- 实验结果：工具池超过 30 个时准确率开始下降，超过 100 个时大幅退化

## 缓解方案

### RAG-MCP 方法
通过语义检索动态筛选工具，只将最相关的工具描述注入 Prompt：
- **Token 减少 50%+**
- **准确率提升 3 倍+**

### 其他潜在方法
- 分层索引（Hierarchical Indexing）
- 自适应检索策略
- 工具分类与按需加载

## 参考

- RAG-MCP 解决方案：[[RAG-MCP]]
- MCP 工具选择：[[MCP-Tool-Selection]]
- RAG 检索机制：[[RAG-for-Tool-Selection]]
