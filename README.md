# YOLO 模型训练、转换与部署说明

这个仓库用于整理乒乓球 `ball` 目标检测模型的训练和部署流程，包含两条路线：

- `yolov5_train/`：官方 Ultralytics YOLOv5 仓库方式，训练的是经典 YOLOv5 架构。
- `yolo_new/`：使用 `ultralytics` Python 包训练 YOLOv8、YOLO11、YOLO12 等新结构模型。

当前数据集配置为单类别检测：

```yaml
path: E:/YOLO/merged
train: train/images
val: valid/images
test: test/images

nc: 1
names: ['ball']
```

## 目录说明

```text
E:\YOLO
├─ yolo_new/                 # YOLOv8/YOLO11/YOLO12 等新结构训练脚本
├─ yolov5_train/             # 经典 YOLOv5 训练配置和辅助脚本
├─ K230_Run/                 # K230 板端运行示例脚本
├─ PingPong/                 # 本地模型文件存放目录，默认不推送大模型
├─ merged/                   # 数据集目录，默认不推送
└─ Model_Traning/            # 原始训练资料/权重/离线包，默认不推送
```

`.gitignore` 已经忽略数据集、虚拟环境、训练输出和大模型文件，避免把 `.pt`、`.onnx`、`.kmodel`、数据集图片等直接推到 GitHub。大模型建议使用 GitHub Releases 或网盘保存。

## 模型结构区别

经典 YOLOv5：

- 使用官方 `ultralytics/yolov5` 仓库的 `train.py`、`export.py`。
- 权重内部类型为 `models.yolo.DetectionModel`。
- 结构中包含 `anchors`、`C3`、`SPPF`、`Detect`。
- 属于 anchor-based 检测模型。

YOLOv8/YOLO11/YOLO12 等新结构：

- 使用 `from ultralytics import YOLO` 的统一接口。
- 训练命令由 `model.train(...)` 发起。
- 新版模型通常为 anchor-free 或新版检测头结构。
- 不能简单把 YOLOv5 的后处理、部署代码直接套到 YOLOv8/11/12 上。

## 一、经典 YOLOv5 训练

### 1. 创建环境

推荐使用已经验证过的 GPU 环境：

```powershell
conda create -n yolov5gpu128 python=3.10 -y
conda activate yolov5gpu128
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128 --no-cache-dir
```

RTX 5060 Laptop GPU 需要支持 `sm_120` 的新版 PyTorch。之前的 `torch 2.5.1+cu121` 能识别 CUDA，但实际计算会报：

```text
CUDA error: no kernel image is available for execution on the device
```

当前已验证可用环境：

```text
Python 3.10.20
torch 2.11.0+cu128
GPU: NVIDIA GeForce RTX 5060 Laptop GPU
CUDA 计算: ok
```

### 2. 克隆 YOLOv5 官方仓库

不要把官方 YOLOv5 仓库本体提交到当前仓库，按需重新克隆即可：

```powershell
cd E:\YOLO\yolov5_train
git clone https://github.com/ultralytics/yolov5.git
cd yolov5
pip install -r requirements.txt
```

### 3. 开始训练

```powershell
conda activate yolov5gpu128
cd E:\YOLO\yolov5_train\yolov5

python -W ignore train.py --img 320 --batch-size 16 --epochs 200 --data "E:\YOLO\yolov5_train\data.yaml" --weights "E:\YOLO\Model_Traning\weights\yolov5\yolov5n.pt" --workers 0 --device 0
```

注意：

- 参数前面是两个横杠，例如 `--img`，不是 `---img`。
- Windows 路径里如果有空格，必须用双引号包起来。
- `--device 0` 表示使用第 1 张 GPU。
- 训练时看 `GPU_mem`，如果不是 `0G`，说明正在使用 GPU。

训练完成后权重一般保存在：

```text
E:\YOLO\yolov5_train\yolov5\runs\train\exp*\weights\best.pt
E:\YOLO\yolov5_train\yolov5\runs\train\exp*\weights\last.pt
```

当前已完成训练的模型位于：

```text
E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.pt
```

本次训练最终指标：

```text
precision:      0.94299
recall:         0.90271
mAP@0.5:        0.94597
mAP@0.5:0.95:   0.70185
```

## 二、经典 YOLOv5 验证和预测

验证测试集：

```powershell
conda activate yolov5gpu128
cd E:\YOLO\yolov5_train\yolov5

python val.py --weights "runs\train\exp2\weights\best.pt" --data "E:\YOLO\yolov5_train\data.yaml" --img 320 --task test --device 0
```

预测图片：

```powershell
python detect.py --weights "runs\train\exp2\weights\best.pt" --source "E:\YOLO\merged\test\images" --img 320 --conf-thres 0.25 --device 0
```

预测结果会保存到：

```text
E:\YOLO\yolov5_train\yolov5\runs\detect\exp*
```

## 三、经典 YOLOv5 转 ONNX

普通 ONNX 导出：

```powershell
conda activate yolov5gpu128
cd E:\YOLO\yolov5_train\yolov5

python export.py --weights "E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.pt" --include onnx --img 320 --opset 11 --simplify --device cpu
```

导出文件：

```text
E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.onnx
```

已验证的 ONNX 信息应类似：

```text
ir_version: 6
opset: 11
input:  images [1, 3, 320, 320]
output: output0 [1, 6300, 6]
```

其中 `output0 [1, 6300, 6]` 是 YOLOv5 单类别检测输出。`6` 通常对应框坐标、置信度和类别信息。

## 四、K230 转换流程

将 ONNX 复制到 K230 转换工作目录：

```powershell
Copy-Item "E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.onnx" "C:\Users\MECHREU\k230-work\yolov5-320.onnx" -Force
```

进入 WSL / Docker：

```bash
chmod -R a+rwX ~/k230-work
docker start -ai k230-converter
cd /workspace
touch test_write && rm test_write
```

转换为 K230 可用模型：

```bash
python /home/user/model_converter/convert_model.py \
  --model /workspace/yolov5-320.onnx \
  --dataset_path /workspace/images \
  --input_width 320 \
  --input_height 320 \
  --target k230 \
  --ptq_option 0
```

如果出现：

```text
ValidationError: Your model ir_version is higher than the checker's.
```

说明 ONNX 版本对转换容器来说太新，不是数据集或权限问题。解决方式是重新用 `--opset 11 --device cpu` 导出，并确认 `ir_version` 是较低版本，例如 `6`。

## 五、K230 板端部署

`K230_Run/` 中有板端 Python 示例：

```text
K230_Run/yolov8.py
K230_Run/yolov12.py
```

板端脚本中需要重点修改：

```python
kmodel_path = "/sdcard/best.kmodel"
self.class_id = ['ball']
model_input_size=[320, 320]
confidence_threshold = 0.6
nms_threshold = 0.2
```

部署步骤：

1. 将转换得到的 `.kmodel` 放到开发板 SD 卡，例如 `/sdcard/best.kmodel`。
2. 将对应的运行脚本放到开发板。
3. 确认脚本中的 `kmodel_path`、类别名、输入尺寸和阈值与模型一致。
4. 在开发板运行脚本。

注意：YOLOv5 和 YOLOv8/11/12 的输出格式和后处理方式可能不同。板端脚本必须和模型输出结构匹配。

## 六、YOLOv8/YOLO11/YOLO12 新结构训练

新结构模型放在 `yolo_new/`，通过 `ultralytics` 包运行。

安装环境：

```powershell
conda create -n yolo python=3.10 -y
conda activate yolo
pip install ultralytics
```

训练示例：

```powershell
conda activate yolo
cd E:\YOLO
python yolo_new\train.py
```

也可以直接使用 `yolo_new` 中整理好的 PowerShell 脚本：

```powershell
E:\YOLO\yolo_new\train_yolo_new.ps1
E:\YOLO\yolo_new\val_yolo_new.ps1
E:\YOLO\yolo_new\predict_yolo_new.ps1
E:\YOLO\yolo_new\resume_yolo_new.ps1
E:\YOLO\yolo_new\export_yolo_new_onnx.ps1
```

核心代码形式：

```python
from ultralytics import YOLO

model = YOLO(r"E:\YOLO\yolo_new\weights\yolo11n.pt")
model.train(
    data=r"E:\YOLO\yolo_new\data.yaml",
    epochs=200,
    batch=16,
    imgsz=320,
    workers=0,
)
```

训练结果通常保存到：

```text
E:\YOLO\runs\detect\train*
```

验证：

```powershell
python yolo_new\test.py
```

预测：

```powershell
python yolo_new\predict.py
```

继续训练：

```powershell
python yolo_new\continue.py
```

导出 ONNX：

```powershell
python yolo_new\export.py
```

新结构模型导出后的 ONNX 输出格式可能与 YOLOv5 不同，部署到 K230 时需要使用匹配的后处理脚本。

## 七、常见问题

### 1. `unrecognized arguments: ---img`

参数写错了。应该是两个横杠：

```powershell
--img 320
```

不是：

```powershell
---img 320
```

### 2. 权重路径带空格导致报错

错误示例：

```text
train.py: error: unrecognized arguments: Traning\weights\...
```

原因是路径里有空格但没有加双引号。正确写法：

```powershell
--weights "E:\YOLO\Model Traning\weights\yolov5\yolov5n.pt"
```

当前仓库建议统一使用无空格路径：

```text
E:\YOLO\Model_Traning
```

### 3. `torch.cuda.is_available()` 是 True 但训练失败

如果显卡是 RTX 5060 Laptop GPU，旧版 PyTorch CUDA 可能不支持 `sm_120`。需要使用支持 CUDA 12.8 的新版 PyTorch，例如当前验证过的：

```text
torch 2.11.0+cu128
```

### 4. 训练很慢

先看训练日志中的 `GPU_mem`：

- `GPU_mem` 为 `0G`：大概率在用 CPU。
- `GPU_mem` 有数值：正在用 GPU。

如果仍然慢，可以降低：

```text
--img 320
--batch-size 8
--workers 0
```

### 5. ONNX 转 K230 报 IR 版本太高

重新导出：

```powershell
python export.py --weights "runs\train\exp2\weights\best.pt" --include onnx --img 320 --opset 11 --simplify --device cpu
```

然后检查：

```powershell
python -c "import onnx; m=onnx.load(r'runs\train\exp2\weights\best.onnx'); print(m.ir_version); print([(o.domain, o.version) for o in m.opset_import])"
```

## 八、推送到 GitHub

首次关联远程仓库：

```powershell
cd E:\YOLO
git remote add origin https://github.com/QingYuan-Chen/Yolo_traing.git
git branch -M main
```

提交说明文件和脚本：

```powershell
git add README.md .gitignore yolo_new yolov5_train K230_Run
git commit -m "Add YOLO training conversion and deployment guide"
git push -u origin main
```

不建议直接提交：

```text
merged/
Model_Traning/
.conda_envs/
.conda_pkgs/
*.pt
*.onnx
*.kmodel
```

这些内容体积大，或者属于本机环境，不适合直接放进 GitHub 仓库。
