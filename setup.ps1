# setup.ps1 —— 一键装依赖：Python + Qt5(MSVC) + VS Build Tools + OpenCV
# 用法：右键“使用 PowerShell 运行”，或在管理员 PowerShell 里跑 .\setup.ps1
# 第一次运行会下载几个 GB，耐心等。

$ErrorActionPreference = "Stop"
Write-Host "===== 1/5 检查 winget / Python =====" -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "没找到 winget，请先安装 应用安装程序(App Installer)。" -ForegroundColor Red
    exit 1
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
    # 刷新当前会话 PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Write-Host "===== 2/5 安装 aqtinstall（脚本化装 Qt 的工具）=====" -ForegroundColor Cyan
python -m pip install --upgrade pip
python -m pip install aqtinstall

Write-Host "===== 3/5 安装 Qt 5.15.2 (MSVC2019 64位) 到 C:\Qt =====" -ForegroundColor Cyan
if (-not (Test-Path "C:\Qt\5.15.2")) {
    python -m aqt install-qt windows desktop 5.15.2 win64_msvc2019_64 --outputdir C:\Qt
} else {
    Write-Host "C:\Qt\5.15.2 已存在，跳过。"
}

Write-Host "===== 4/5 安装 Visual Studio Build Tools 2022 (C++ 编译器) =====" -ForegroundColor Cyan
if (-not (Get-Command cl -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e `
        --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
} else {
    Write-Host "cl.exe 已在 PATH，跳过。"
}

Write-Host "===== 5/5 下载并解压 OpenCV 4.10，设置 OPENCV_DIR =====" -ForegroundColor Cyan
$opencvDir = "C:\opencv\build"
if (-not (Test-Path $opencvDir)) {
    $exe = "$env:TEMP\opencv_4.10.0_windows.exe"
    Invoke-WebRequest -Uri "https://github.com/opencv/opencv/releases/download/4.10.0/opencv-4.10.0-windows.exe" -OutFile $exe
    # 自解压包：静默解压到 C:\
    Start-Process -FilePath $exe -ArgumentList "-o C:\ -y" -Wait
}
[Environment]::SetEnvironmentVariable("OPENCV_DIR", $opencvDir, "User")
$env:OPENCV_DIR = $opencvDir

Write-Host "`n===== 装完了 =====" -ForegroundColor Green
Write-Host "OPENCV_DIR = $opencvDir"
Write-Host "下一步：用 Qt Creator 打开 video_handel.pro，选 MSVC2019 64-bit Kit，构建运行。"
Write-Host "或命令行编译（在 VS 的 x64 Native Tools 命令行里）："
Write-Host "  C:\Qt\5.15.2\msvc2019_64\bin\qmake.exe video_handel.pro"
Write-Host "  nmake"
