#!/usr/bin/env bash
set -euo pipefail
# SkillSpector 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://docs.nvidia.com/skills/scanning-agent-skills
# 更新日期：2026-10-26
# 类型：script
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }
command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || { echo "需要先安装 Python 3"; exit 1; }

mkdir -p .download
cd .download

python3 -m venv .venv
.venv/bin/pip install https://github.com/NVIDIA/skillspector/releases/download/v2.13.1/skillspector-2.13.1-py3-none-any.whl
echo "安装完成：用 .venv/bin/skillspector scan <技能目录> --no-llm 扫描"

echo ""

echo "安装完成：用 .venv/bin/skillspector scan <技能目录> --no-llm 扫描（Windows 为 .venv\Scripts\skillspector.exe）"
echo "若结果异常或需要改配置，请参考官方文档：https://docs.nvidia.com/skills/scanning-agent-skills"
