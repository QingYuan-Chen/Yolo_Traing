# Model_Traning 目录说明

这个目录主要用于保存本地训练资料、离线依赖包、数据集原始文件和常用预训练权重。

## 预训练模型文件说明

YOLO 训练时是否会自动下载预训练模型，取决于脚本里写的是“模型名称”还是“本地路径”。

### 1. 写模型名称

例如新版 Ultralytics YOLO：

```python
model = YOLO("yolo11n.pt")
model = YOLO("yolov8n.pt")
```

或者经典 YOLOv5：

```powershell
python train.py --weights yolov5n.pt
```

这种写法通常会在本地没有模型文件时，尝试联网自动下载官方预训练权重。

### 2. 写本地路径

例如：

```python
model = YOLO(r"E:\YOLO\yolo_new\weights\yolo11n.pt")
```

或者：

```powershell
python train.py --weights "E:\YOLO\Model_Traning\weights\yolov5\yolov5n.pt"
```

这种写法表示明确指定本地模型文件。路径中的 `.pt` 文件必须真实存在，否则训练会报找不到文件。

## 建议

- 常用模型可以保存在本地，例如 `weights/yolov5/yolov5n.pt`。
- 不常用模型可以删除，后面需要时再下载。
- 如果希望别人 clone GitHub 仓库后能直接联网下载模型，脚本中可以写模型名称，例如 `yolo11n.pt` 或 `yolov5n.pt`。
- 如果希望固定使用某个本地模型版本，脚本中就写完整本地路径。

注意：`.pt` 预训练模型只是训练起点，不是训练代码本身。删除不用的预训练模型不会影响已经训练好的 `best.pt`，但如果脚本引用了被删除的模型路径，下次训练会失败。

## weights 下载链接方案

`weights` 目录里的 `.pt` 文件属于大模型文件，不适合直接提交到普通 Git 仓库。仓库中保留统一脚本：

```powershell
.\Model_Traning\prepare_release_assets.ps1
.\Model_Traning\download_assets.ps1
```

打包发布用：

```powershell
powershell -ExecutionPolicy Bypass -File .\Model_Traning\prepare_release_assets.ps1 weights
```

这个脚本会在桌面生成 `yolo-weight-release-assets` 文件夹，里面有一个 `weights.zip`。把它上传到 GitHub Release，Release tag/name 使用：

```text
weights-pretrained
```

别人 clone 仓库后下载权重用：

```powershell
powershell -ExecutionPolicy Bypass -File .\Model_Traning\download_assets.ps1 weights
```

## wheels 目录说明

`wheels` 目录中存放的是 Python 离线安装包，文件后缀通常是 `.whl`。

例如：

```text
torch-2.8.0+cu128-xxx.whl
torchvision-xxx.whl
ultralytics-xxx.whl
opencv_python-xxx.whl
numpy-xxx.whl
pandas-xxx.whl
```

`.whl` 可以理解成 Python 包的安装压缩包。平时执行：

```powershell
pip install ultralytics
pip install torch
pip install opencv-python
```

pip 会从网上下载这些包。如果提前把 `.whl` 文件下载到本地，就可以离线安装。

单个安装示例：

```powershell
pip install E:\YOLO\Model_Traning\wheels\ultralytics-8.3.180-py3-none-any.whl
```

从 `wheels` 目录离线安装示例：

```powershell
pip install --no-index --find-links E:\YOLO\Model_Traning\wheels ultralytics
```

简单区分：

```text
weights = 模型权重文件，例如 .pt
wheels  = Python 软件包安装文件，例如 .whl
```

所以 `wheels` 不是模型库，也不是训练结果。它主要用于无网络、下载慢、或者需要复现 Python 环境时安装依赖。

## wheels 下载链接方案

`wheels` 目录体积很大，不适合直接提交到普通 Git 仓库。仓库中使用同一组统一脚本：

```powershell
.\Model_Traning\prepare_release_assets.ps1
.\Model_Traning\download_assets.ps1
```

打包发布用：

```powershell
powershell -ExecutionPolicy Bypass -File .\Model_Traning\prepare_release_assets.ps1 wheels
```

这个脚本会在桌面生成 `yolo-wheel-release-assets` 文件夹，其中普通 wheel 会打包成 `wheels-non-torch.zip`，超大的 `torch` wheel 会切成多个 `.partXX` 分片。把这些文件上传到 GitHub Release，Release tag/name 使用：

```text
wheels-cu128
```

别人 clone 仓库后下载依赖用：

```powershell
powershell -ExecutionPolicy Bypass -File .\Model_Traning\download_assets.ps1 wheels
```

下载完成后，离线安装依赖：

```powershell
pip install --no-index --find-links .\Model_Traning\wheels -r .\Model_Traning\requirements.txt
```
