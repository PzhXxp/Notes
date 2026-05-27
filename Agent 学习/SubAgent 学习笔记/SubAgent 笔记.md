
- [ ] 为什么需要子 SubAgent？
- [ ] 如何触发 SubAgent？
	- [ ] 通过“同时”、“并行”等命令触发
	- [ ] SubAgent 上下文不共享



# SubAgent 设计准则

1. SubAgent 只做一件事情
2. SubAgent 只做工具调用
3. 对话由主 Agent 处理

> [!info]
>  主模型做对话是免费的能力——它本来就在和用户聊天，不需要额外调度。subagent
  做的是需要工具（Read/Grep）的脏活。各取所长。
  

