# 禁用 CONDA 插件以及取消频道提示
$env:CONDA_NO_PLUGINS = "true"
$env:CONDA_NUMBER_CHANNEL_NOTICES = "0"

# 指定 conda 的环境路径和包下载缓存路径
$env:CONDA_ENVS_PATH = "E:\YOLO\.conda_envs"
$env:CONDA_PKGS_DIRS = "E:\YOLO\.conda_pkgs"

# 设定虚拟环境的存放路径以及 yolov5 源码仓库路径
$envPath = "E:\YOLO\.conda_envs\yolov5"
$repoPath = "E:\YOLO\yolov5_train\yolov5"

# 若环境不存在则创建基于 python 3.9 的新环境
if (!(Test-Path $envPath)) {
  conda create --solver=classic -p $envPath python=3.9 -y
}

# 激活新创建或已存在的 conda 虚拟环境
conda activate $envPath

# 若源码仓库不存在则通过 Git 克隆 yolov5 官方代码
if (!(Test-Path $repoPath)) {
  git clone https://github.com/ultralytics/yolov5.git $repoPath
}

# 切换工作目录到 yolov5 源码目录，并安装所需的所有依赖
Set-Location $repoPath
pip install -r requirements.txt
