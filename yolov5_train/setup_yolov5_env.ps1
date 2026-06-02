$env:CONDA_NO_PLUGINS = "true"
$env:CONDA_NUMBER_CHANNEL_NOTICES = "0"
$env:CONDA_ENVS_PATH = "E:\YOLO\.conda_envs"
$env:CONDA_PKGS_DIRS = "E:\YOLO\.conda_pkgs"

$envPath = "E:\YOLO\.conda_envs\yolov5"
$repoPath = "E:\YOLO\yolov5_train\yolov5"

if (!(Test-Path $envPath)) {
  conda create --solver=classic -p $envPath python=3.9 -y
}

conda activate $envPath

if (!(Test-Path $repoPath)) {
  git clone https://github.com/ultralytics/yolov5.git $repoPath
}

Set-Location $repoPath
pip install -r requirements.txt
