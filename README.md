# SkillSpector 一键部署指南

> 第三方部署指南 · 非 SkillSpector 官方仓库。官方项目：[NVIDIA/SkillSpector](https://github.com/NVIDIA/SkillSpector)
> 内容来自官方文档（2026-10-26）。项目迭代快，请以[官方文档](https://docs.nvidia.com/skills/scanning-agent-skills)为准。

[![⚡ 一键部署](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键部署推荐用百度搭子)

## 一键部署（推荐：用百度搭子）

> [!TIP]
> 不用自己配 Python 依赖，让百度搭子把扫描器装好，装技能前先跑一遍。

⚠️ 需要 Python 3.10+，装的是命令行工具，没有网页界面。带 LLM 的深度分析要配模型凭据；只做静态规则扫描可加 `--no-llm`。MCP 模式需要额外依赖。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/skillspector-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会建好独立 Python 环境，装上官方 Release 里的 wheel，不污染系统 Python，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）



## SkillSpector 是什么？

SkillSpector 是开源的NVIDIA 的 Agent 技能安全扫描器（协议：Apache-2.0，<img src="https://img.shields.io/github/stars/NVIDIA/SkillSpector?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

在装 Agent 技能之前先做安全体检：静态分析加可选的 LLM 深度分析，查提示注入、数据外泄、危险命令、供应链与嵌套产物，输出 JSON / Markdown 报告，可接进 CI 做门禁。

- 输入：技能目录、`SKILL.md`、zip 包、GitHub 地址
- 输出：JSON / Markdown 报告，适合做安装前门禁
- 两种用法：命令行 `skillspector scan`，或 `skillspector mcp` 给 Agent 调用
- 背景：NVIDIA Verified Skills 流水线的一部分

（来源：[官方仓库](https://github.com/NVIDIA/SkillSpector)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 21.7k stars | Apache-2.0 开源，NVIDIA 维护 |
| 用途明确 | 装技能前回答「这个技能安全吗」 |
| 输出可接 CI | JSON / Markdown，能卡安装流程 |
| 多种输入 | 目录、SKILL.md、zip、GitHub 地址都行 |
| 有 Docker 与 MCP 模式 | 能塞进流水线或交给 Agent 调用 |

| 需要注意 | 说明 |
|---|---|
| Windows 源码构建会失败 | 实测 hatchling 报 `Errno 9`，要用 Release wheel 或 Docker |
| LLM 分析要凭据 | 不配模型只能用静态规则 |
| MCP 模式要额外依赖 | wheel 安装不含 `[mcp]` |
| 会误报 | 规则命中不等于真有问题，需要看报告细节 |
| 只覆盖已支持的检查项 | 不能替代完整代码审计 |

> 以上基于官方文档与社区反馈整理（2026-10-26），以官方最新文档为准。

## 快速部署（官方方式）

```bash
python3 -m venv .venv
.venv/bin/pip install https://github.com/NVIDIA/skillspector/releases/download/v2.13.1/skillspector-2.13.1-py3-none-any.whl
echo "安装完成：用 .venv/bin/skillspector scan <技能目录> --no-llm 扫描"
```

部署步骤来源：[https://github.com/NVIDIA/SkillSpector#installation](https://github.com/NVIDIA/SkillSpector#installation)

## 验证状态

| 场景 | 状态 |
|---|---|
| 从 Release wheel 安装成功（v2.13.1），skillspector --help 正常输出 | 已验证 2026-10-26 |
| 从源码构建在 Windows 上失败（hatchling Errno 9），已写入坑位 | 已验证 2026-10-26 |
| MCP 模式（[mcp] extra）未实测 | 已核对 2026-10-26 |
| MCP 服务握手与工具列表（initialize / tools/list） | 已验证 2026-10-26 |
| 非目标宿主调用被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-26 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

SkillSpector 支持 `skillspector mcp` 作为 MCP server 暴露扫描能力，安装时要带 `[mcp]` extra。本仓库的 MCP 只提供安装步骤与常见坑。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-26）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\skillspector-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 安装完成后：怎么扫

```bash
.venv/bin/skillspector scan ./某个技能目录/ --no-llm
.venv/bin/skillspector scan ./某个技能目录/ --format json --output report.json
.venv/bin/skillspector scan https://github.com/<作者>/<技能仓库>
```

常用参数：

- `--no-llm`：只跑静态规则，不调用模型，最快
- `--format json|markdown`：输出格式
- `--output`：写到文件，方便接 CI

### 要 MCP 模式怎么办

Release 里的 wheel 不含 `[mcp]` 额外依赖。需要 `skillspector mcp` 时，按官方文档用 uv 装带 extra 的版本：

```bash
uv tool install 'skillspector[mcp] @ git+https://github.com/NVIDIA/skillspector.git'
```

> 扫描结果是风险提示，不等于“绝对安全”；高危项仍要人工看上下文。

## 常见坑

- 不要 `pip install git+...`：Windows 上源码构建实测报 `OSError: [Errno 9] Bad file descriptor`，用 Release 里的 wheel 或 Docker
- 命令找不到：装在 `.venv` 里，先激活环境或用全路径
- 默认会尝试 LLM 分析：只想快速扫就加 `--no-llm`
- 要 `skillspector mcp` 得带 `[mcp]` extra，wheel 版不含
- 远程地址和 zip 有大小上限（防 zip bomb），超大技能包会被拒绝
- 扫描通过不代表绝对安全，装之前仍要看技能要什么权限

## 免责声明

本仓库为第三方指南，与 SkillSpector 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-26），项目迭代快，请以[官方文档](https://docs.nvidia.com/skills/scanning-agent-skills)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
