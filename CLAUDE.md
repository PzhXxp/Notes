# Karpathy LLM Wiki 系统

## 核心流程

raw/ 中的原始文件由 Claude 直接处理 → wiki/ 结构化知识。
**不使用脚本**，所有操作（扫描、分类、创建笔记、更新索引）由 Claude 完成。

---

## 目录结构

```
raw/                      ← 原始文件存放处（未处理 / 已处理）
  *.md

wiki/                     ← 处理后知识库
  index.md                ← 主索引（raw→wiki 映射、分类、摘要）
  log.md                  ← 更新日志
  agent/                  ← [大类] AI Agent
    rag/                  ← [小类] RAG 技术
    skills/               ← [小类] Skills 开发
    context/              ← [小类] Context 管理
    harness/              ← [小类] Harness 开发
    mcp/                  ← [小类] MCP 协议
  python/                 ← [大类] Python
  concepts/               ← [大类] 核心概念
  papers/                 ← [大类] 论文精读
```

---

## Raw→Wiki 处理指令

当用户说 **"处理 raw"** 或 **"更新 wiki"** 时，执行以下管线：

### Step 1：扫描（Claude 使用 Glob + Read）

```
Glob("raw/*.md")           → 列出所有 raw 文件
对每个文件 Read(frontmatter) → 检查 status 字段
筛选出 status != "processed" 的文件
```

### Step 2：分类 + 摘要（Claude 分析内容）

读取未处理 raw 文件的正文，判断：
- **大类**（agent / python / concepts / papers / 其他）
- **小类**（Agent 下细分：rag / skills / context / harness / mcp）
- **生成中文摘要**（1-2 句话）
- **判断是否需拆分**（一篇 raw 可能映射到多个 wiki 概念）
- **处理文件名**：将 raw 文件名标准化为 wiki 文件名（英文短横线命名）

### Step 3：创建 Wiki 笔记

在 `wiki/<大类>/<小类>/` 下创建 `.md` 文件：
- 标准 frontmatter（created, tags, related, source）
- 正文：用自己的话重组，包含核心理解
- 使用 `[[wikilink]]` 互联

### Step 4：更新 wiki/index.md

在对应分类表格中新增条目：
| Raw 源文件 | Wiki 笔记 | 摘要 |
| 文件名      | 笔记链接   | 中文摘要 |

如果分类不存在，自动创建新表格。

### Step 5：更新 wiki/log.md

追加一条处理记录（日期、raw 文件、分类、wiki 笔记列表）。

### Step 6：标记 raw 文件为已处理

在 raw 文件的 frontmatter 中添加：
```yaml
status: processed
processed_at: 2026-05-26
```

---

## 分类规则

| 大类 | 小类 | 内容特征 |
|------|------|---------|
| agent | rag | RAG、检索增强、向量数据库、Embedding |
| agent | skills | Claude Skills、Hook、Skill 开发 |
| agent | context | Context 管理、Prompt 工程 |
| agent | harness | Claude Code Harness、Sandbox、配置 |
| agent | mcp | MCP 协议、Function Calling、工具调用 |
| python | — | Python 语法、库、实践 |
| concepts | — | 跨领域核心概念 |
| papers | — | 学术论文精读 |

> 分类体系是动态扩展的，遇到新领域自动创建新分类。

---

## 增量保证

- **每次只处理新增 raw 文件**（status 不是 processed 的）
- 已处理过的文件永远不会被重复处理（raw 是 write-once，只增不改）

---

## 处理示例

```
raw/RAG-MCP...md
  → 分类: agent > rag
  → 拆分创建:
    wiki/agent/rag/RAG.md
    wiki/agent/rag/MCP.md
    wiki/agent/rag/RAG-MCP.md
    wiki/agent/rag/Prompt-Bloat.md
    wiki/papers/RAG-MCP-2025.md
  → index.md 更新 Agent > RAG 表格
  → log.md 追加处理记录
  → raw 文件标记 status: processed
```
