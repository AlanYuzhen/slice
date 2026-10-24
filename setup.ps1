# setup.ps1 —— 一键装依赖：Python + Qt5(MSVC) + VS Build Tools + OpenCV
# 用法：双击 setup.bat，或右键“使用 PowerShell 运行”。需要管理员权限，脚本会自己申请。

# 自动申请管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限，正在申请...（请在弹窗里点“是”）" -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "===== 1/5 检查 winget，安装 Python =====" -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "没找到 winget，请先从应用商店安装 应用安装程序(App Installer)。" -ForegroundColor Red
    Read-Host "按回车退出"; exit 1
}

# 找 python.exe，找不到就装
function Find-Python {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "C:\Python312\python.exe",
        "C:\Python311\python.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    return $null
}

$python = Find-Python
if (-not $python) {
    Write-Host "安装 Python 3.12 ..."
    winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements --silent
    # 刷新 PATH 后再找
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $python = Find-Python
}
if (-not $python) {
    Write-Host "Python 仍未找到，请重启电脑后再跑一次脚本。" -ForegroundColor Red
    Read-Host "按回车退出"; exit 1
}
Write-Host "使用 Python: $python" -ForegroundColor Green

Write-Host "===== 2/5 安装 aqtinstall（脚本化装 Qt 的工具）=====" -ForegroundColor Cyan
& $python -m pip install --upgrade pip
& $python -m pip install aqtinstall

Write-Host "===== 3/5 安装 Qt 5.15.2 (MSVC2019 64位) 到 C:\Qt =====" -ForegroundColor Cyan
if (-not (Test-Path "C:\Qt\5.15.2\msvc2019_64")) {
    & $python -m aqt install-qt windows desktop 5.15.2 win64_msvc2019_64 --outputdir C:\Qt
} else {
    Write-Host "C:\Qt\5.15.2 已存在，跳过。"
}

Write-Host "===== 4/5 安装 Visual Studio Build Tools 2022 (C++ 编译器) =====" -ForegroundColor Cyan
Write-Host "注意：会弹安装窗口，请不要取消；等它自己跑完。" -ForegroundColor Yellow
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-source-agreements --accept-package-agreements `
    --override "--passive --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

Write-Host "===== 5/5 下载并解压 OpenCV 4.10，设置 OPENCV_DIR =====" -ForegroundColor Cyan
$opencvDir = "C:\opencv\build"
if (-not (Test-Path $opencvDir)) {
    $exe = "$env:TEMP\opencv_4.10.0_windows.exe"
    Write-Host "下载 OpenCV（约 120MB）..."
    Invoke-WebRequest -Uri "https://github.com/opencv/opencv/releases/download/4.10.0/opencv-4.10.0-windows.exe" -OutFile $exe
    Write-Host "解压到 C:\ ..."
    Start-Process -FilePath $exe -ArgumentList "-o C:\ -y" -Wait
}
[Environment]::SetEnvironmentVariable("OPENCV_DIR", $opencvDir, "User")

Write-Host "`n===== 全部装完了 =====" -ForegroundColor Green
Write-Host "OPENCV_DIR = $opencvDir"
Write-Host "下一步：打开 Qt Creator（开始菜单里），打开 video_handel.pro，选 MSVC2019 64-bit Kit，点构建运行。"
Read-Host "按回车退出"
