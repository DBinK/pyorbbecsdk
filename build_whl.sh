#!/bin/bash

GREEN='\033[0;32m'  # Green color
NC='\033[0m'        # No Color

log() {
    echo -e "[INFO]${GREEN}$1${NC} "
}

PYTHON_VERSION=3.10  # 目标 Python 版本 3.10 ~ 3.12 测试通过

log "目标 Python 版本: $PYTHON_VERSION"
log "正在安装依赖..."

# 固定 Python 版本并同步依赖
uv python pin $PYTHON_VERSION
uv sync

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

cd ..

# 删除旧 wheel
rm -f dist/*.whl

# 生成 wheel 包
log "正在生成 wheel 包..."
python3 setup.py bdist_wheel

# 安装 wheel 包
log "正在安装 wheel 包..."
uv pip install dist/*.whl --force-reinstall

log "完成！"
log "可以使用以下命令测试安装:"
log "uv run examples/hello_orbbec.py"