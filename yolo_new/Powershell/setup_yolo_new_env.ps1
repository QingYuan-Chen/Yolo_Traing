$env:CONDA_NO_PLUGINS = "true"
$env:CONDA_NUMBER_CHANNEL_NOTICES = "0"

# New Ultralytics YOLO environment for YOLOv8, YOLO11, YOLO12, etc.
# If the environment already exists, this script only activates it and updates ultralytics.
conda create -n yolo python=3.10 -y
conda activate yolo

python -m pip install --upgrade pip
pip install ultralytics

python -c "import ultralytics; print('ultralytics', ultralytics.__version__)"
