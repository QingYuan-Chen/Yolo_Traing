$env:CONDA_NO_PLUGINS = "true"
$env:CONDA_NUMBER_CHANNEL_NOTICES = "0"

# 为 YOLOv8, YOLO11, YOLO12 等创建一个新的 Ultralytics YOLO 环境。
# 如果环境已经存在，此脚本只会激活它并更新 ultralytics 库。
conda create -n yolo python=3.10 -y
conda activate yolo

# 升级 pip 到最新版本
python -m pip install --upgrade pip
# 安装官方 ultralytics 包
pip install ultralytics

# 打印并检查已安装的 ultralytics 版本
python -c "import ultralytics; print('ultralytics', ultralytics.__version__)"
