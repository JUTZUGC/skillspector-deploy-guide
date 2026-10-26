# SkillSpector 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://docs.nvidia.com/skills/scanning-agent-skills
# 更新日期：2026-10-26
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw '需要先安装 Python 3' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

python -m venv .venv
.venv\Scripts\python.exe -m pip install https://github.com/NVIDIA/skillspector/releases/download/v2.13.1/skillspector-2.13.1-py3-none-any.whl ; if ($LASTEXITCODE -ne 0) { throw '安装失败，请查看上面的输出' }
Write-Host '安装完成：用 .venv\Scripts\skillspector.exe scan <技能目录> --no-llm 扫描'

Write-Host ''

Write-Host '安装完成：用 .venv/bin/skillspector scan <技能目录> --no-llm 扫描（Windows 为 .venv\Scripts\skillspector.exe）'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://docs.nvidia.com/skills/scanning-agent-skills'
