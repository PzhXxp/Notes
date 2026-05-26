---
created: 2026-05-26T23:22:54+08:00
source: "https://arxiv.org/html/2505.03275v1"
title: "RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation"
tags:
  - "Clipings"
---
# 摘要

本文介绍RAG-MCP框架，将检索增强生成（RAG）与模型上下文协议（MCP）结合，通过语义检索仅将最相关的MCP工具描述输入到大语言模型，有效缓解提示词膨胀问题。实验表明，RAG-MCP在工具选择准确率上比基线方法提升三倍以上（43.13% vs 13.62%），同时大幅减少提示词数量，为大规模外部工具集成提供了可扩展且准确的方案。

# 正文

###### Abstract

Large language models (LLMs) struggle to effectively utilize a growing number of external tools, such as those defined by the Model Context Protocol (MCP) [^1], due to prompt bloat and selection complexity. We introduce RAG-MCP, a Retrieval-Augmented Generation framework that overcomes this challenge by offloading tool discovery. RAG-MCP uses semantic retrieval to identify the most relevant MCP(s) for a given query from an external index before engaging the LLM. Only the selected tool descriptions are passed to the model, drastically reducing prompt size and simplifying decision-making. Experiments, including an MCP stress test, demonstrate RAG-MCP significantly cuts prompt tokens (e.g., by over 50%) and more than triples tool selection accuracy (43.13% vs 13.62% baseline) on benchmark tasks. RAG-MCP enables scalable and accurate tool integration for LLMs.

###### Keywords:

Retrieval-Augmented Generation Model Context Protocol Tool Selection

## 1 Introduction

### 1.1 Background and Motivation

Large Language Models (LLMs) have demonstrated remarkable capabilities in natural dialogue, reasoning, and even code generation. However, they remain fundamentally constrained by the knowledge encoded in their parameters and the fixed context window available at inference time. In essence, an LLM without external access is “trapped” with only its training data and cannot easily update its knowledge or perform actions in the world [^12]. To address this limitation, recent efforts have focused on augmenting LLMs with external tools and function-calling abilities [^3]. By invoking tools (e.g. web search, databases, calculators) via defined functions or APIs, an LLM can fetch up-to-date information and execute complex operations beyond its built-in repertoire [^12]. This paradigm - often referred to as zero-shot tool use or function calling — allows AI assistants to interface with the latest data and services, unlocking applications from real-time knowledge queries to specialized tasks in finance and travel planning [^3]. In fact, major AI providers have embraced this trend: for example, leading LLM platforms now support plugin APIs and structured function calls so that models like GPT-4 or Claude can invoke external services through well-defined interfaces [^12].

In the research community, a variety of approaches have been proposed to enable and improve LLM tool use. Prompt-based strategies such as ReAct intermix reasoning steps with action commands, allowing an LLM to decide when to consult a tool in the context of a multi-turn “thought process” [^15]. Model-centric approaches have also emerged: for instance, Toolformer fine-tunes an LLM to autonomously decide which API to call, when to call it, and how to incorporate the result, given only a handful of demonstrations per tool [^13] Other researchers have improved tool-use by incorporating it into training data and model tuning. This includes blending function call demonstrations into instruction-following datasets and exploring prompt formats that effectively describe available functions to the model [^3]. Such efforts have markedly enhanced zero-shot tool usage performance. For example, fine-tuning a model on API call tasks with extensive tool-use data can yield impressive results – the Gorilla system augmented a 7B LLaMA-based model with relevant API documentation retrieval, enabling it to outperform even GPT-4 in generating correct API calls for a wide range of tools [^12]. An important insight from these works is that providing just-in-time relevant context (be it through optimized prompts or retrieved documentation) greatly boosts the accuracy of an LLM’s tool selection and use, while mechanisms for the model to explicitly decide on tool use (such as special decision tokens for “answer vs. act”) can further improve reliability [^3].

Despite this progress, a new challenge arises as we scale up the number of tools available to an LLM. Most prior studies and deployments consider a relatively small set of tools or APIs, often hand-picked and easy for the model to handle within a prompt [^12]. In practice, however, the ecosystem of tools is rapidly expanding. For instance, Anthropic’s recently introduced Model Context Protocol (MCP) defines a universal, open standard for connecting AI systems with external data sources and services. MCP enables a single assistant to interface with many data repositories and business tools through a unified protocol, replacing fragmented one-off integrations. As a result, an advanced LLM agent could soon have dozens of functions at its disposal – from Google Drive and Slack connectors to GitHub, databases, maps, and more – all registered as MCP “tools” it can call [^1]. This proliferation of available tools brings significant hurdles.

Prompt Bloat is one critical issue: providing the definitions or usage instructions for every possible tool in the model’s context would consume an enormous number of tokens and risk overwhelming the model. It has been observed that it is effectively impossible to describe a large collection of APIs or tools in a single prompt as their number grows, and many APIs have overlapping functionalities with only nuanced differences. Including too many at once not only exhausts the context length, but can also confuse the model – the functions may start to blur together. This leads directly to a second issue: decision overhead. With a long list of tools (many of them similar in scope), the model faces a more complex decision when choosing if and which tool to invoke. The greater the choice, the higher the chance of error, such as selecting an suboptimal tool or misinterpreting what a tool does. Indeed, even state-of-the-art models can misfire in such settings: for example, in a scenario with numerous API options, GPT-4 was reported to hallucinate an API that doesn’t actually exist, and Anthropic’s Claude picked the wrong library for the user’s request [^12]. These failure cases underscore that naively scaling up the toolset can degrade an LLM’s performance, due to both the capacity strain on the prompt and the ambiguity in the model’s decision process.

![Refer to caption](https://arxiv.org/html/2505.03275v1/extracted/6377532/RAG_MCP.png)

Figure 1: Comparation between MCP and RAG-MCP during inference

To tackle these challenges, we propose RAG-MCP, a solution that marries Retrieval-Augmented Generation (RAG) with the Model Context Protocol framework. The key idea of RAG-MCP is to avoid presenting all tools to the language model at once, and instead dynamically retrieve a relevant subset of tools based on the user’s query. In our approach, the numerous available tool descriptions (MCP function schemas, usage examples, etc.) are stored in an external memory indexed by their semantics. When a new query arrives, a dedicated retriever (e.g. a vector-space semantic search) first selects the top- $k$ candidate tools that are most likely to be useful for that query. Only these $k$ tool descriptions are then injected into the LLM’s prompt (or provided via the function-calling API), greatly reducing context length and complexity. This retrieval step serves as a form of focused context filtering, which cuts down on prompt bloat and guides the model’s choice. The approach is analogous to how retrieval-augmented QA systems work: rather than feed the entire Wikipedia to the model, one retrieves only the relevant articles [^6]. Here, instead of static knowledge, we retrieve actionable tool knowledge on the fly. An added benefit is extensibility – because the tool information lives in an external index, new tools or updated APIs can be incorporated by updating that index without retraining the LLM, ensuring the system remains up-to-date [^12]. In short, retrieval helps tame the growing toolset by providing the right tools at the right time, thereby reducing the model’s decision burden.

### 1.2 Contributions

In summary, this paper makes the following contributions:

1. RAG-MCP Framework: We introduce a novel architecture that integrates a retrieval mechanism with LLM function calling in the MCP setting. To our knowledge, this is one of the first frameworks to enable an LLM to handle a large arsenal of tools by querying a tool repository for relevant options instead of naively prompting with all tools. This design retains the flexibility of the open MCP ecosystem while imposing structure to maintain tractability.
2. Scalable Tool Retrieval: We develop a semantic tool retrieval module that represents each available tool’s description in a vector space and efficiently matches user queries to the most pertinent tools. This significantly reduces prompt size and complexity (mitigating prompt bloat) and improves decision making by narrowing the choices. The LLM, guided by this retrieved context, can more accurately select and use the correct external tool, even as the total number of tools grows large. Notably, our approach allows new tools to be added on the fly by indexing them, without requiring additional fine-tuning of the LLM.
3. Improved Tool-Use Performance: Through comprehensive experiments, we demonstrate that RAG-MCP effectively addresses the performance degradation that occurs with naively scaling up the tool set. On a suite of tool-augmented NLP tasks, we show that as the number of available functions increases, a baseline LLM’s success rate in selecting and executing the correct tool drops markedly (illustrating the aforementioned challenge). However, under the RAG-MCP strategy, the model’s performance is largely restored to its original level, and in some cases even exceeds the small-toolset baseline. In particular, RAG-MCP yields substantially higher accuracy in choosing the appropriate tool and reduces errors such as hallucinated or mis-parameterized function calls. These results underscore the efficacy of using retrieval to scale up tool-use: the proposed method enables an LLM to maintain high tool-selection accuracy and reliability even with a large pool of tools, paving the way for more scalable and capable tool-augmented AI systems.

Overall, our work demonstrates that the integration of retrieval-based context management is a promising direction to counteract the challenges of tool proliferation in LLMs. By enabling models to learn which tool to use out of many and only providing information for those tools, RAG-MCP offers a practical solution for the next generation of AI agents operating with extensive toolkits. It combines the strengths of retrieval augmentation and standardized tool APIs to ensure that more tools do not mean worse performance but rather a broader range of skills that the model can deploy accurately and efficiently.

## 2 Related Work

### 2.1 Tool Use in LLMs

LLMs have been augmented with external tools to overcome limitations in arithmetic, retrieval, and code execution. Toolformer demonstrates a self-supervised method by which a model learns when and how to call APIs such as calculators or search engines, improving zero-shot performance across tasks [^13]. ReAct interleaves chain-of-thought reasoning with action steps to interact with external environments (e.g., a Wikipedia API), yielding more interpretable and accurate multi-step solutions [^15]. WebGPT fine-tunes GPT-3 in a simulated browser environment, training it to navigate, search, and cite sources for long-form Q&A, reducing hallucinations via grounded retrieval [^9]. More recently, ChatGPT Plugins introduced a production plugin ecosystem, allowing ChatGPT to access up-to-date information and third-party services in a controlled, safety-oriented framework [^11].

### 2.2 Retrieval-Augmented Generation

Retrieval-Augmented Generation (RAG) first combined parametric LLMs with non-parametric memory in a dense vector index, retrieving relevant passages at inference time to improve knowledge-intensive tasks [^6]. Subsequent work has extended RAG to broad NLP paradigms, including modular and advanced RAG variants that dynamically adapt retrieval per token or per query [^4]. RAG’s decoupling of memory access and generation inspires our MCP-RAG approach, wherein MCP discovery is treated as a retrieval subproblem, orthogonal to core text generation.

### 2.3 Model Context Protocol

The Model Context Protocol standardizes LLM-to-API interactions by bundling resource prompts, authentication, and parameter schemas into modular “MCP” servers. MCPs act as function-call extensions, similar to OpenAI’s function-calling API, but with greater community extensibility. The rapid growth of MCP repositories (4,400+ servers on mcp.so as of April 2025 [^14]) underscores the need for scalable discovery and validation mechanisms.

## 3 Methodology

Overview. We study how the number of available MCP servers affects an LLM’s ability to select and invoke the correct tool (“prompt bloat”) and present MCP-RAG, a retrieval-augmented framework that mitigates this degradation by dynamically retrieving only the most relevant MCP for each query.

### 3.1 Prompt Bloat and the MCP Stress Test

Modern LLMs must often choose among many possible external tools, each described by an MCP schema. As the count of MCPs grows, including all their descriptions in a single prompt leads to prompt bloat: the context window becomes saturated with distractors, reducing the model’s capacity to distinguish and recall the correct tool.

This phenomenon parallels the Needle-in-a-Haystack (NIAH) test, which embeds a random fact (the “needle”) in the middle of a long context (the “haystack”) and measures an LLM’s ability to retrieve it under varying context lengths and depths [^6] [^10]. In NIAH, performance drops sharply as the haystack grows, revealing limits of in-context retrieval.

Inspired by NIAH, we design an MCP stress test on WebSearch tasks: for each trial, we present the model with $N$ MCP schemas (one ground-truth and $N-1$ distractors) and ask it to select and invoke the correct WebSearch MCP. We vary $N$ from 1 to 11100 in 26 intervals, measuring selection accuracy, task success, prompt token usage, and latency. This setup quantifies how tool-selection ability degrades with increasing MCP pool size.

### 3.2 RAG-MCP Framework

To overcome prompt bloat, RAG-MCP applies Retrieval-Augmented Generation (RAG) principles to tool selection. Instead of flooding the LLM with all MCP descriptions, we maintain an external vector index of all available MCP metadata. At query time:

1. Retrieval. A lightweight LLM-based retriever (e.g., Qwen) encodes the user’s task description and performs a semantic search over the MCP index, returning the top- $k$ candidate MCPs most similar to the task [^6].
2. Validation. For each retrieved MCP, RAG-MCP can generate a few-shot example query and test its response to ensure basic compatibility, functioning as a “sanity check” before invocation.
3. Invocation. Only the single best MCP description, including its tool-use parameters, is injected into the LLM prompt or function-calling API, which then performs planning and execution without concern for tool discovery [^2].

This design yields several benefits:

- Reduced Prompt Size. By supplying only relevant MCP metadata, RAG-MCP avoids context window overload even when the full tool registry is large.
- Lower Cognitive Load. The LLM no longer needs to sift through hundreds of distractors, improving selection accuracy and reducing hallucinations [^2].
- Resource Efficiency. Unlike conventional MCP clients (e.g., Claude or early GPT-4 integrations) that must instantiate all registered MCP servers before interaction, MCP-RAG activates only the selected MCP, lowering startup cost and enabling support for arbitrarily large toolsets without infrastructure bottlenecks [^10].
- Multi-Turn Robustness. In dialogues spanning many turns, the LLM need not re-include all MCP prompts; RAG-MCP’s retriever handles tool recall dynamically, freeing context space for task-specific reasoning.

### 3.3 Three-Step Pipeline Diagram

We summarize RAG-MCP’s operation in three core steps. The flowchart is shown in Fig. 3:

1. Task Input → Retriever: The user’s natural-language task is encoded and submitted to the retriever.
2. Retriever → MCP Selection & Validation: The retriever searches the vector index of MCP schemas, ranks candidates by semantic similarity, and optionally tests each via synthetic examples.
3. LLM Execution with Selected MCP: The LLM receives only the selected MCP’s schema and parameters and executes the task via the function-calling interface.

![Refer to caption](https://arxiv.org/html/2505.03275v1/extracted/6377532/process.png)

Figure 2: RAG-MCP pipeline: (1) encode user query with Qwen-max, (2) re-trieve & validate top-k MCPs, and (3) invoke chosen MCP

By decoupling tool discovery from generation, RAG-MCP ensures that LLMs can scale to hundreds or thousands of MCPs without suffering prompt bloat or decision fatigue, much as RAG systems avoid overwhelming an LLM with entire corpora by retrieving only relevant passages.

### 3.4 Discussion

Our methodology combines the rigor of stress testing (via the MCP stress test) with the effectiveness of retrieval-augmented tool use. The stress test quantifies the sharp performance drop that occurs when distractor MCPs swell the prompt, mirroring long-context recall failures in NIAH evaluations [^5]. RAG-MCP then counteracts this by dynamically narrowing the toolset, reducing both prompt tokens and decision complexity, and thereby restoring—and often improving—task success rates.

Furthermore, by using an external index, RAG-MCP remains extensible: new MCPs can be added by indexing their metadata, without retraining the LLM. And by selectively activating servers on demand, it sidesteps the practical limits on simultaneous MCP instantiation faced by prior tool-augmented LLM deployments.

## 4 Experiments

### 4.1 Stress Test

#### 4.1.1 Setup

To quantify how an LLM’s tool-selection ability scales with the size of the MCP pool, we conduct a stress test in which the number of candidate MCP servers, $N$, is varied from 1 to 11100 in intervals, while the key MCP server located from the top to the bottom. For each value of $N$, we randomly select one “ground-truth” MCP (i.e., the only server capable of satisfying the task requirement) and $N-1$ distractor MCPs drawn from our full registry of over 4,400 publicly listed servers [^14]. This design ensures that exactly one in every $N$ candidates is relevant. We then present the model with each of $20$ web-search tasks, requiring it to (a) choose the correct MCP, (b) issue a valid query or answer, and (c) return the final result.

![Refer to caption](https://arxiv.org/html/2505.03275v1/extracted/6377532/heat_map.png)

Figure 3: This figure illustrates per-trial success across MCP positions from 1 to 11100, where yellow denotes successful selection and purple denotes failure.

#### 4.1.2 Results

Figure3 plots selection accuracy and task success as $N$ increases. We observe a clear non-monotonic trend: These results quantitatively confirm that while MCP-RAG greatly mitigates prompt bloat and maintains high performance in small to moderate pools, its retrieval precision and overall throughput degrade as the tool registry scales to thousands of MCPs.“‘

### 4.2 RAG-MCP

#### 4.2.1 Setup

We evaluated all methods in the web search subset of MCPBench [^8], which we used as our heldout testbed. For each baseline, we perform 20 independent trials, and we deem a baseline successful if it produces more than 10 correct answers out of those 20. Within each trial, the model may engage in up to 10 rounds of interaction with the MCP servers in order to arrive at its final response.

To assess answer correctness in an automated and reproducible manner, we employ Deepseek-v3 [^7] as our evaluator. Because MCP servers require external network access—and can therefore be sensitive to latency or transient failures—we enforce a controlled network environment throughout all experiments, ensuring no requests fail due to connectivity issues. Finally, all trials are driven by qwen-max-0125 as our underlying base LLM.

#### 4.2.2 Baselines

We evaluate three selection strategies in our experiments:

1. Blank Conditioning: Prompt the LLM with all $N$ MCP descriptions at once and ask it to choose the correct one.
2. Actual Match: Pre-filter the candidate pool using simple keyword matching on the task description and MCP metadata, then prompt the model on this reduced set.
3. RAG-MCP: Employ our vector-index retriever to semantically rank all $N$ MCPs and inject only the top candidate’s schema into the LLM prompt for execution.

#### 4.2.3 Metrics

We evaluate performance using three key metrics for each baseline method:

- Accuracy (%): Percentage of trials in which the model selected the ground-truth MCP.
- Avg Prompt Tokens: Mean number of tokens consumed by the prompt, including injected MCP metadata.
- Avg Completion Tokens: Mean number of tokens generated by the model as its final output.

Judgment of the final answer is automated using a Llama-based verifier (“Llama as Judge”) to compare model outputs against ground truth.

#### 4.2.4 Results

Table 1 summarizes the performance of the evaluated baseline methods, clearly demonstrating the effectiveness of MCP-RAG:

| Baseline | Accuracy (%) | Avg Prompt Tokens | Avg Completion Tokens |
| --- | --- | --- | --- |
| MCP-RAG | 43.13 | 1084.00 | 78.14 |
| Actual Match | 18.20 | 1646.00 | 23.60 |
| Blank | 13.62 | 2133.84 | 162.25 |

Table 1: Baseline performance comparison on accuracy and token usage

As the table shows, MCP-RAG achieves the highest accuracy at 43.13%, significantly outperforming the Actual Match and Blank Conditioning methods, which scored 18.20% and 13.62%, respectively. Furthermore, MCP-RAG notably reduces the average number of prompt tokens to 1084, reflecting a substantial reduction compared to the other baselines, especially Blank Conditioning, which requires 2133.84 tokens. While MCP-RAG shows an increase in completion tokens (78.14) compared to Actual Match (23.60), this trade-off is beneficial as it correlates with a higher accuracy and overall task success rate.

## 5 Analysis

#### 5.0.1 Stress Test Analysis

Figure 3 illustrates per-trial success across MCP positions from 1 to 11100, where yellow denotes successful selection and purple denotes failure. We observe that:

- High Early-Stage Success: MCP positions below 30 exhibit predominantly yellow regions, indicating success rates above 90% when the candidate pool is minimal.
- Mid-Range Variability: In the range of positions 31–70, clusters of purple emerge intermittently, reflecting lower accuracy as semantic overlap among MCP descriptions increases.
- Performance Degradation at Scale: Beyond position ~100, purple dominates, signifying that retrieval precision diminishes when handling very large tool registries.
- Residual Success Islands: Occasional yellow patches at higher positions suggest that certain MCPs remain well-aligned to specific queries, providing robustness even in extensive pools.

These patterns confirm that while MCP-RAG effectively curbs prompt bloat and maintains high accuracy in small to moderate MCP pools, retrieval precision challenges arise as the total number of MCPs grows, motivating future work on hierarchical or adaptive retrieval mechanisms.

### 5.1 Analysis of RAG-MCP Results

The superior performance of RAG-MCP can be attributed to several factors:

- Focused Context Filtering: By injecting only the single most relevant MCP schema, the model avoids the distraction caused by irrelevant tool descriptions, resulting in clearer decision boundaries.
- Prompt Efficiency: The dramatic reduction in prompt tokens allows the model to allocate more of its context window to reasoning about the task itself rather than parsing extraneous metadata.
- Balanced Generation: Although RAG-MCP slightly increases completion token usage relative to Actual Match, this overhead reflects more thorough reasoning and verification steps, which correlate with higher accuracy.

Overall, these findings confirm that retrieval-augmented selection of MCPs effectively tames prompt bloat and enhances an LLM’s tool-selection reliability, making RAG-MCP a compelling solution for scalable external tool integration.

## 6 Conclusion

We present RAG-MCP, a simple yet powerful framework that tames large MCP toolsets by retrieving only the most relevant schema for each query. With focused retrieval, RAG-MCP:

- Drastically reduces prompt size, cutting token usage by over half compared to feeding all tools at once.
- Boosts selection accuracy, more than tripling the success rate of naïve and keyword-based methods under heavy load.
- Maintains extensibility, since new MCPs can be indexed on–the–fly without retraining the model.

In essence, RAG-MCP turns a sprawling library of hundreds or thousands of tools into a lean, on-demand toolkit. Future work will refine retrieval at extreme scale—via hierarchical indexes or adaptive strategies—and explore multi-tool workflows and real-world agent deployments. RAG-MCP lays the “golden core” for scalable, reliable LLM agents that wield vast external services with precision and efficiency.

## References

## 7 Acknowledgements

We gratefully acknowledge Zhiling Luo, Xiaorong Shi, Xuanrui Lin, and Jinyang Gao for their seminal report “Evaluation Report on MCP Servers.” Their publicly released code framework and the accompanying WebSearch dataset formed the foundation on which our own work was developed.

[^1]: Anthropic: Introducing the model context protocol (2024), [https://www.anthropic.com/news/model-context-protocol](https://www.anthropic.com/news/model-context-protocol)

[^2]: Blog, N.: What is retrieval-augmented generation aka rag (2025), [https://blogs.nvidia.com/blog/what-is-retrieval-augmented-generation/](https://blogs.nvidia.com/blog/what-is-retrieval-augmented-generation/)

[^3]: Chen, Y.C., Hsu, P.C., Hsu, C.J., Shiu, D.s.: Enhancing function-calling capabilities in llms: Strategies for prompt formats, data integration, and multilingual translation. arXiv preprint arXiv:2412.01130 (2024)

[^4]: Gao, Y., Xiong, Y., Gao, X., Jia, K., Pan, J., Bi, Y., Dai, Y., Sun, J., Wang, H., Wang, H.: Retrieval-augmented generation for large language models: A survey. arXiv preprint arXiv:2312.10997 2 (2023)

[^5]: gkamradt: The needle in a haystack test (2024), [https://github.com/gkamradt/LLMTest\_NeedleInAHaystack](https://github.com/gkamradt/LLMTest_NeedleInAHaystack)

[^6]: Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., Küttler, H., Lewis, M., Yih, W.t., Rocktäschel, T., Riedel, S., Kiela, D.: Retrieval-augmented generation for knowledge-intensive nlp tasks. In: Larochelle, H., Ranzato, M., Hadsell, R., Balcan, M., Lin, H. (eds.) Advances in Neural Information Processing Systems. vol. 33, pp. 9459–9474. Curran Associates, Inc. (2020), [https://proceedings.neurips.cc/paper\_files/paper/2020/file/6b493230205f780e1bc26945df7481e5-Paper.pdf](https://proceedings.neurips.cc/paper_files/paper/2020/file/6b493230205f780e1bc26945df7481e5-Paper.pdf)

[^7]: Liu, A., Feng, B., Xue, B., Wang, B., Wu, B., Lu, C., Zhao, C., Deng, C., Zhang, C., Ruan, C., et al.: Deepseek-v3 technical report. arXiv preprint arXiv:2412.19437 (2024)

[^8]: Luo, Z., Shi, X., Lin, X., Gao, J.: Evaluation report on mcp servers (2025), [https://arxiv.org/abs/2504.11094](https://arxiv.org/abs/2504.11094)

[^9]: Nakano, R., Hilton, J., Balaji, S., Wu, J., Ouyang, L., Kim, C., Hesse, C., Jain, S., Kosaraju, V., Saunders, W., Jiang, X., Cobbe, K., Eloundou, T., Krueger, G., Button, K., Knight, M., Chess, B., Schulman, J.: Webgpt: Browser-assisted question-answering with human feedback (2022), [https://arxiv.org/abs/2112.09332](https://arxiv.org/abs/2112.09332)

[^10]: OpenAI: Openai function calling, [https://platform.openai.com/docs/guides/function-calling](https://platform.openai.com/docs/guides/function-calling)

[^11]: OpenAI: Chatgpt plugins (2023), [https://openai.com/index/chatgpt-plugins](https://openai.com/index/chatgpt-plugins)

[^12]: Patil, S.G., Zhang, T., Wang, X., Gonzalez, J.E.: Gorilla: Large language model connected with massive apis. Advances in Neural Information Processing Systems 37, 126544–126565 (2024)

[^13]: Schick, T., Dwivedi-Yu, J., Dessi, R., Raileanu, R., Lomeli, M., Hambro, E., Zettlemoyer, L., Cancedda, N., Scialom, T.: Toolformer: Language models can teach themselves to use tools. In: Oh, A., Naumann, T., Globerson, A., Saenko, K., Hardt, M., Levine, S. (eds.) Advances in Neural Information Processing Systems. vol. 36, pp. 68539–68551. Curran Associates, Inc. (2023), [https://proceedings.neurips.cc/paper\_files/paper/2023/file/d842425e4bf79ba039352da0f658a906-Paper-Conference.pdf](https://proceedings.neurips.cc/paper_files/paper/2023/file/d842425e4bf79ba039352da0f658a906-Paper-Conference.pdf)

[^14]: ShipAny: Mcp servers (2025), [https://mcp.so/](https://mcp.so/)

[^15]: Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., Cao, Y.: React: Synergizing reasoning and acting in language models. International Conference on Learning Representations (ICLR) (2023), [https://par.nsf.gov/biblio/10451467](https://par.nsf.gov/biblio/10451467)

# 链接

[RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation](https://arxiv.org/html/2505.03275v1)

---
> [!info]- 元信息
> - **标题**: RAG-MCP: Mitigating Prompt Bloat in LLM Tool Selection via Retrieval-Augmented Generation
> - **URL**: https://arxiv.org/html/2505.03275v1
> - **抓取时间**: 2026-05-26 23:22

# 反向链接

<!-- 由 Clippings-to-WIKI 脚本自动填充，请勿手动删除 -->