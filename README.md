# Python Bindings for Orbbec SDK

This main branch provides Python bindings for the [Orbbec SDK v1.x](https://github.com/orbbec/OrbbecSDK), allowing developers to interface with Orbbec devices in Python.
the OrbbecSDK_V2.x branch provides Python bindings for the [Orbbec SDK v2.x](https://github.com/orbbec/OrbbecSDK-dev),The differences between Orbbec SDK v2.x and Orbbec SDK v1.x can be found in the [README](https://github.com/orbbec/OrbbecSDK-dev).

## Custom Build Modifications
你现在的内容已经很好了，我帮你稍微整理成 **中英文对照、排版更清晰、GitHub 风格一致** 的版本，同时保留你新增的安装提示：

---

## Custom Build Modifications

**自定义构建修改**

This project includes several custom modifications to the build process by Clicko. Key modifications include:

本项目包含了由 Clicko 对构建流程所做的若干自定义修改。主要修改包括：

* Use `uv` to quickly synchronize dependencies.
  使用 `uv` 快速同步依赖项。

* Fix stubs files (`.pyi`) not included in built `.whl` packages, which prevented IDEs from providing auto-completion.
  修复构建生成的 `.whl` 包中未包含 stubs 文件（`.pyi`）的问题，导致 IDE 无法自动补全。

* Add a `build_whl.sh` script for building wheels quickly.
  添加 `build_whl.sh` 脚本，用于快速构建 wheel 包。

For detailed build script modifications, please refer to the [`build_whl.sh`](build_whl.sh) script.

有关构建脚本修改的详细信息，请参阅 [`build_whl.sh`](build_whl.sh) 脚本。


Before running the build script, you may need to install `uv` and the CMake build toolchain:

运行脚本前，可能需要先安装 `uv` 和 CMake 构建工具链：

```bash
sudo apt update
sudo apt install gcc cmake python3-dev -y
curl -LsSf https://astral.sh/uv/install.sh | sh
```

than you can run the build script:
然后你可以运行构建脚本：

```bash
bash ./build_whl.sh
```

Modify the variable `PYTHON_VERSION` in the script to change the target build version
修改脚本中的变量 `PYTHON_VERSION` 可更换目标构建版本


## Hardware Products Supported by Python SDK

| **products list** | **firmware version**        |
| ----------------- | --------------------------- |
| Gemini 335        | 1.2.20                      |
| Gemini 335L       | 1.2.20                      |
| Gemini 336        | 1.2.20                      |
| Gemini 336L       | 1.2.20                      |
| Femto Bolt        | 1.0.6/1.0.9                 |
| Femto Mega        | 1.1.7/1.2.7                 |
| Gemini 2 XL       | Obox: V1.2.5 VL:1.4.54      |
| Astra 2           | 2.8.20                      |
| Gemini 2 L        | 1.4.32                      |
| Gemini 2          | 1.4.60 /1.4.76              |
| Astra+            | 1.0.22/1.0.21/1.0.20/1.0.19 |
| Femto             | 1.6.7                       |
| Femto W           | 1.1.8                       |
| DaBai             | 2436                        |
| DaBai DCW         | 2460                        |
| DaBai DW          | 2606                        |
| Astra Mini Pro    | 1007                        |
| Gemini E          | 3460                        |
| Gemini E Lite     | 3606                        |
| Gemini            | 3.0.18                      |
| Astra Mini S Pro  | 1.0.05                      |

## Getting Started

### Get the Source Code

Clone the repository to get the latest version of the Python bindings for Orbbec SDK.

```bash
git clone https://github.com/orbbec/pyorbbecsdk.git
```

### Install Dependencies

Install the necessary Python development packages on Ubuntu.

```bash
sudo apt-get install python3-dev python3-venv python3-pip python3-opencv
```

### Custom Python3 Path (Optional)

If you use Anaconda, set the Python3 path to the Anaconda path in `pyorbbecsdk/CMakeLists.txt` before the `find_package(Python3 REQUIRED COMPONENTS Interpreter Development)` line:

```cmake
set(Python3_ROOT_DIR "/home/anaconda3/envs/py3.6.8") # Replace with your Python3 path
set(pybind11_DIR "${Python3_ROOT_DIR}/lib/python3.6/site-packages/pybind11/share/cmake/pybind11") # Replace with your Pybind11 path
```

### Build the Project

Create a virtual environment and build the project.

```bash
cd pyorbbecsdk
python3 -m venv ./venv
source venv/bin/activate
pip3 install -r requirements.txt
mkdir build
cd build
cmake -Dpybind11_DIR=`pybind11-config --cmakedir` ..
make -j4
make install
```

### Try the Examples

Set up your environment to run examples and install necessary system rules.

```bash
cd pyorbbecsdk
export PYTHONPATH=$PYTHONPATH:$(pwd)/install/lib/
sudo bash ./scripts/install_udev_rules.sh
sudo udevadm control --reload-rules && sudo udevadm trigger
python3 examples/depth_viewer.py
python3 examples/net_device.py # Requires ffmpeg installation for network device
```

Additional examples are available in the `examples` directory. Please see [examples/README.md](examples/README.md) for further details.

### Generate Stubs

Generate Python stubs for better IntelliSense in your IDE.

```bash
source env.sh
pip3 install pybind11-stubgen
pybind11-stubgen pyorbbecsdk
```

### Building on Windows

For instructions on how to build and run the examples on Windows, please refer to [docs/README.md](docs/README_EN.md).

## Making a Python Wheel

Generate a wheel package for easy distribution and installation.

```bash
cd pyorbbecsdk
python3 -m venv ./venv
source venv/bin/activate
pip3 install -r requirements.txt
mkdir build
cd build
cmake -Dpybind11_DIR=`pybind11-config --cmakedir` ..
make -j4
make install
cd ..
pip3 install wheel
python3 setup.py bdist_wheel
pip3 install dist/*.whl
```

## Enabling Device Timestamps via UVC Protocol on Windows

To get device timestamps through the UVC protocol on a Windows system, you must modify the registry by completing a registration process. This is required due to default system limitations. Follow the steps below to configure your system:

### 1. Connect the Device
- Ensure your UVC-compatible device is connected to the computer and recognized by the system. Confirm that the device is online and functioning.

### 2. Open PowerShell with Administrator Privileges
- Open the Start menu, type `PowerShell`, right-click on the PowerShell app, and select 'Run as administrator'.

### 3. Navigate to the Scripts Directory
- Use the `cd` command to change the directory to the location of your scripts.
  ```powershell
  cd scripts
  ```

### 4. Modify Execution Policy
- Modify the PowerShell execution policy to allow script execution. Run the following command and press `Y` when prompted to confirm the change:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### 5. Execute the Registration Script
- Run the registration script to modify the registry settings. Use the following command:
  ```powershell
  .\obsensor_metadata_win10.ps1 -op install_all
  ```

This will complete the necessary registration and modification of settings to allow device timestamps via the UVC protocol on your Windows system.


## Documentation

For detailed documentation, please refer to [docs/README.md](docs/README_EN.md).

## License

This project is licensed under the Apache License 2.0.
