# ==============================
# Windows CLI build script
# pyorbbecsdk (PowerShell)
# ==============================

$ErrorActionPreference = "Stop"

function Log($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Green
}

# Python 版本（仅说明，不强制）
$PYTHON_VERSION = "3.10"
Log "目标 Python 版本: $PYTHON_VERSION"

# 清理虚拟环境
if (Test-Path ".venv") {
    Log "删除旧的 .venv"
    Remove-Item .venv -Recurse -Force
}

# uv 同步依赖
Log "固定 Python 版本并同步依赖"
uv python pin $PYTHON_VERSION
uv sync


# 激活虚拟环境
Log "激活虚拟环境"
.\.venv\Scripts\Activate.ps1

# 清理构建目录
Log "清理旧构建目录"
Remove-Item build, install, dist -Recurse -Force -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Path build | Out-Null
New-Item -ItemType Directory -Path install\lib | Out-Null

# 进入 build 目录
Set-Location build

# 生成 Ninja 构建规则
Log "生成 Ninja 构建规则"

$PYTHON_EXE = uv run python -c "import sys; print(sys.executable)"
$PYBIND11_CMAKE = uv run python -m pybind11 --cmakedir

cmake .. -G Ninja `
    -DPython3_EXECUTABLE="$PYTHON_EXE" `
    -DCMAKE_PREFIX_PATH="$PYBIND11_CMAKE"

# 编译 + 安装
Log "开始编译"
ninja 

Log "安装到 install 目录"
ninja install

Set-Location ..


# 生成 stubs
Log "生成类型提示文件 (.pyi)"
uv pip install .
pybind11-stubgen pyorbbecsdk
Copy-Item stubs\pyorbbecsdk.pyi install\lib -Force

# 复制示例和配置文件
New-Item -ItemType Directory -Force install\lib\pyorbbecsdk
Copy-Item examples install\lib\pyorbbecsdk -Recurse -Force
Copy-Item config install\lib\pyorbbecsdk -Recurse -Force
Copy-Item requirements.txt install\lib\pyorbbecsdk\examples -Force

# 删除旧 wheel
Remove-Item dist\*.whl -Force -ErrorAction SilentlyContinue

# 生成 wheel
Log "生成 wheel 包"
uv run python setup.py bdist_wheel

# 安装 wheel 包
Log "正在安装 wheel 包到当前环境, 用于测试..."
uv pip install dist/*.whl --force-reinstall

# 测试安装
Log "编译完成！生成的 .whl 文件保存在 dist/ 中"
Log "正在运行 uv run examples/hello_orbbec.py 测试安装"

uv run examples/hello_orbbec.py