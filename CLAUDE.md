# Obsidian 编译器知识库

## 核心哲学

本知识库采用**编译器模式**——将原始信息（raw）编译为结构化知识（wiki），实现"一次摄入、永久链接、持续迭代"。

```
raw/          →    wiki/          →    outputs/
输入源材料        编译后知识          问答产出
(只读不修改)      (AI 生成笔记)        (查询记录)
```

---

## 目录结构

```
.
├── raw/                        ← 原始文件（只读，永不修改正文）
│   ├── articles/               ← 文章、博客
│   ├── papers/                 ← 学术论文 PDF/MD
│   ├── claude-transcripts/     ← 对话记录
│   └── misc/                   ← 其他未分类源
│
├── wiki/                       ← 编译后知识（AI 生成）
│   ├── _index.md               ← 主索引（raw→wiki 映射 + 分类总览）
│   ├── _log.md                 ← 操作日志（Ingest/Query/Lint 记录）
│   ├── concepts/               ← 核心概念（跨领域）
│   ├── people/                 ← 人物笔记
│   ├── papers/                 ← 论文精读
│   └── sources/                ← 源文摘要
│
├── outputs/                    ← 问答产出
│   └── qa-log.md               ← 问答记录（问题 + 回答 + 来源）
│
└── CLAUDE.md                   ← 本文件
```

> **约定**：`raw/` 下的原始文件只读永不修改正文（仅追加 frontmatter 状态标记）；`wiki/` 为 AI 编译产物，持续迭代优化；`outputs/` 为查询副产品。

---

## 命名与格式规范

### 文件命名：kebab-case

```
✅ good: retrieval-augmented-generation.md
✅ good: andrew-ng-2024-talk.md
✅ good: attention-is-all-you-need.md
❌ bad: RAG_MCP 论文.md
❌ bad: My Notes (2).md
```

### YAML Frontmatter

每个 wiki 笔记**必须**包含以下字段：

```yaml
---
title: 检索增强生成
tags:
  - rag
  - llm
  - nlp
date: 2026-05-27
confidence: high         # high / medium / low / seed
source: "[[raw/articles/some-source.md]]"
aliases:
  - RAG
  - 检索增强
related:
  - "[[concepts/embedding]]"
  - "[[concepts/vector-database]]"
status: seedling         # seedling / growing / evergreen
---
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `title` | ✅ | 中文或英文标题 |
| `tags` | ✅ | 标签数组，用于分类和检索 |
| `date` | ✅ | 创建或最后更新日期 |
| `confidence` | ✅ | 置信度：`high` / `medium` / `low` / `seed`（种子笔记） |
| `source` | — | 源文件链接（wiki 笔记指向 raw 源） |
| `aliases` | — | 别名，便于 [[wikilink]] 匹配 |
| `related` | — | 相关笔记的双向链接 |
| `status` | — | 成熟度：`seedling`(幼苗) / `growing`(成长) / `evergreen`(常青) |

### 链接格式：[[wikilink]]

- 内部链接全部使用 `[[笔记名]]` 或 `[[目录/笔记名]]`
- 如果有别名：`[[笔记名|显示文本]]`
- 原始文件引用：`[[raw/articles/file-name.md|源文件]]`

---

## 三大核心操作

---

### 1. Ingest（摄入）

将 raw 中的新源文件编译为 wiki 结构化知识。

**触发词**：`开始摄入` / `ingest`

**管线**：

```
Step 1: 扫描
  Glob("raw/**/*.md") → 读取每个文件的 frontmatter
  筛选出 status != "processed" 的文件

Step 2: 分析
  Read 文件正文 → 判断类型（概念/人物/论文/源文）
  提取核心论点、关键术语、引用来源

Step 3: 创建 Wiki 笔记
  根据类型选择模板创建笔记：
  ├── 概念 → wiki/concepts/<kebab-name>.md
  ├── 人物 → wiki/people/<kebab-name>.md
  ├── 论文 → wiki/papers/<kebab-name>.md
  └── 源文摘要 → wiki/sources/<kebab-name>.md

Step 4: 建立双链
  扫描已有 wiki 笔记，发现关联：
  - 在新建笔记的 related 字段添加 [[链接]]
  - 在已有笔记的 related 字段反向添加 [[新建笔记]]

Step 5: 更新索引
  在 wiki/_index.md 对应分类表格中新增条目

Step 6: 更新日志
  在 wiki/_log.md 追加摄入记录

Step 7: 标记 raw
  在 raw 文件 frontmatter 中添加：
  status: processed
  processed_at: 2026-05-27
```

---

### 2. Query（查询）

在 wiki 知识库中检索并回答问题，新发现回写 wiki。

**触发词**：`查询` / `query` / `问` + 问题

**流程**：

```
Step 1: 检索
  - 优先在 wiki/ 中搜索相关内容
  - 使用 tags、标题匹配、全文检索

Step 2: 推理
  - 基于 wiki 现有知识回答问题
  - 如果知识不足，说明"当前 wiki 中未找到"，询问是否从 raw 或外部补充

Step 3: 存档
  - 将问题和回答追加到 outputs/qa-log.md
  - 格式：
    ## 2026-05-27: 问题简述
    **问题**: ...
    **回答**: ...
    **来源**: [[wikilink]], [[wikilink]]

Step 4: 回写（如果有新洞察）
  - 如果回答中产生了 wiki 中不存在的新知识
  - 创建新的 wiki 笔记或补充到现有笔记
  - 更新 _index.md 和 _log.md
```

**优先级规则**：
1. `wiki/` 内已有知识 > `raw/` 源文件 > 外部搜索
2. `confidence: high` 的笔记优先引用
3. `status: seedling` 的笔记需标注"待验证"

---

### 3. Lint（检查）

对 wiki 知识库进行健康检查，发现并报告问题。

**触发词**：`检查` / `lint` / `体检`

**检查项**：

| 检查项 | 说明 | 修复方式 |
|--------|------|---------|
| 🔗 孤立页面 | 没有任何 [[链接]] 指向的 wiki 笔记 | 关联到相关笔记或在 _index.md 中标记 |
| ⛓️ 断链 | [[链接]] 指向不存在的文件 | 创建占位笔记或修正链接 |
| 🕸️ 陈旧内容 | 超过 90 天未更新的笔记 | 复审并补充新信息 |
| ⚡ 矛盾 | 多篇笔记对同一概念描述不一致 | 统一术语，合并或交叉引用 |
| 🌱 未成熟种子 | confidence:seed 且超过 30 天未升级 | 复审：补充来源或删除 |
| 📄 孤儿 raw | raw 文件已标记 processed 但 wiki 无对应 | 执行 Ingest 或修正标记 |
| 🏷️ 标签不一致 | 同类笔记使用了不同标签 | 统一标签体系 |

**输出格式**：

```markdown
## Lint 报告 — 2026-05-27

### 🔗 孤立页面（2）
- [[wiki/concepts/old-idea]] — 无入链，建议关联或归档

### ⛓️ 断链（3）
- [[wiki/concepts/embedding]] 被 [[foo]] 引用但文件不存在

### ✅ 共 42 个 wiki 笔记，7 个 raw 文件，无严重问题
```

---

## 笔记模板

### 概念模板 (`wiki/concepts/<name>.md`)

```yaml
---
title: 概念名称
tags:
  - tag1
  - tag2
date: 2026-05-27
confidence: medium
aliases:
  - 别名1
related:
  - "[[related-concept]]"
  - "[[another-concept]]"
status: seedling
---
```

> **一句话定义**：用一句话精确概括这个概念是什么。

## 核心要点

- 要点一
- 要点二
- 要点三

## 详细解释

展开阐述概念的背景、原理、工作机制。用自己的话重组，避免直接翻译。

## 关系图谱

- **上游**：[[父概念]] — 此概念的基础/前提
- **下游**：[[子概念]] — 由此概念衍生/应用
- **并列**：[[兄弟概念]] — 同层级的关联概念
- **对立**：[[对立概念]] — 相反或竞争性概念

## 来源

- [[raw/articles/source-file.md|源文件]]
- [[papers/related-paper]]

## 思考与质疑

- 这个概念的局限性是什么？
- 它与现有知识有何冲突？
- 哪些部分置信度较低（待验证）？
```

---

### 源文摘要模板 (`wiki/sources/<name>.md`)

```yaml
---
title: 源文标题
tags:
  - source
  - 作者名
date: 2026-05-27
confidence: high
source: "[[raw/articles/original-file.md]]"
related:
  - "[[concepts/extracted-concept]]"
status: evergreen
---
```

> **TL;DR**：用两三句话概括整篇源文的核心内容。

## 核心论点

1. 论点一（支持证据）
2. 论点二（支持证据）
3. 论点三（支持证据）

## 关键引用

> 原文引用 1 — [[raw/articles/original-file.md|位置]]

> 原文引用 2 — [[raw/articles/original-file.md|位置]]

## 提取的概念

- [[concepts/concept-a]] — 源文如何阐述此概念
- [[concepts/concept-b]] — 源文如何阐述此概念

## 我的思考

- 与现有认知的一致/冲突之处
- 可以应用的场景
- 悬而未决的问题

---

## 人物模板 (`wiki/people/<name>.md`)

```yaml
---
title: 人物姓名
tags:
  - person
  - 领域
date: 2026-05-27
confidence: medium
aliases:
  - 昵称/笔名
related:
  - "[[papers/their-paper]]"
  - "[[concepts/their-idea]]"
status: growing
---
```

> **一句话定位**：此人是谁，核心贡献是什么。

## 背景

履要与领域专长。

## 核心贡献

- 贡献一
- 贡献二

## 关联

- [[papers/paper-title]] — 此人的代表作
- [[concepts/related-concept]] — 此人提出/发展的概念

---

## 论文精读模板 (`wiki/papers/<name>.md`)

```yaml
---
title: 论文标题
tags:
  - paper
  - 领域
date: 2026-05-27
confidence: high
source: "[[raw/papers/original-file.pdf]]"
related:
  - "[[concepts/related-concept]]"
status: growing
---
```

> **问题**：论文试图解决什么问题？
> **方法**：提出了什么方法？
> **结论**：核心发现是什么？

## 背景与动机

## 方法详解

## 实验结果

## 局限性

## 与现有知识的关系

- [[concepts/concept-a]] — 印证/挑战/扩展

---

## 快速命令参考

| 操作 | 触发词 | 行为 |
|------|--------|------|
| **Ingest** | `开始摄入` / `ingest` | 扫描 raw 新文件 → 创建 wiki 笔记 → 建立双链 → 更新索引 |
| **Query** | `查询` / `query` / `问` ... | 检索 wiki 回答 → 存档到 outputs → 新洞察回写 wiki |
| **Lint** | `检查` / `lint` / `体检` | 检查孤立页面、断链、陈旧内容、矛盾、种子笔记 |
| **创建概念** | `新建概念 <名称>` | 用概念模板创建 wiki/concepts/<name>.md |
| **创建摘要** | `新建摘要 <源文件>` | 用源文摘要模板创建 wiki/sources/<name>.md |
| **关联** | `关联 <A> <B>` | 在 A 和 B 的 related 字段互相添加 [[链接]] |
| **升级** | `升级 <笔记>` | 提升笔记的 confidence 和/或 status（需提供依据） |

---

## 增量保证

- **Ingest 幂等**：只处理 `status != "processed"` 的 raw 文件
- **raw 只写一次**：raw 文件的内容永不修改，仅追加 frontmatter 标记
- **wiki 持续迭代**：wiki 笔记可以不断更新、补充、链接
- **不重复造轮子**：Query 时优先使用 wiki 已有知识，新知识再写回

---

> **本文件本身也是 wiki 的一部分** — 如有变更，请更新 _log.md。
