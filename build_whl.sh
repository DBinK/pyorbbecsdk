#!/bin/bash

# 可能你需要先安装 uv 和 cmake 构建工具链
# sudo apt update
# sudo apt install gcc cmake python3-dev -y 
# curl -LsSf https://astral.sh/uv/install.sh | sh

GREEN='\033[0;32m'  # Green color
NC='\033[0m'        # No Color

log() {
    echo -e "[INFO] ${GREEN}$1${NC} "
}

PYTHON_VERSION=3.10  # 目标 Python 版本, 3.10 ~ 3.12 测试通过

log "目标 Python 版本: $PYTHON_VERSION"
log "正在安装依赖..."

# 固定 Python 版本并同步依赖
uv python pin $PYTHON_VERSION
uv sync

# 激活虚拟环境
log "激活 uv 创建的虚拟环境..."
source .venv/bin/activate

# 清理旧的构建目录
rm -rf build install dist
mkdir build
cd build

# 生成 Makefile
log "正在生成 Makefile..."
cmake -Dpybind11_DIR=$(pybind11-config --cmakedir) ..

# 编译（多线程）
NPROC=$(($(nproc)-1))
[ $NPROC -lt 1 ] && NPROC=1
log "使用 $NPROC 个线程编译..."
make -j$NPROC

# 安装库到 install 目录
make install

cd ..  # 回到项目根目录

# 生成 stubs
log "正在生成 stubs, 有报错请忽略..."
pybind11-stubgen pyorbbecsdk
cp stubs/pyorbbecsdk.pyi install/lib

# 删除旧 wheel
rm -f dist/*.whl

# 生成 wheel 包
log "正在生成 wheel 包..."
python3 setup.py bdist_wheel

# 安装 wheel 包
log "正在安装 wheel 包到当前环境, 用于测试..."
uv pip install dist/*.whl --force-reinstall

# 测试安装
log "编译完成！生成的 .whl 文件保存在 dist/ 中"
log "正在运行 uv run examples/hello_orbbec.py 测试安装"

uv run examples/hello_orbbec.py