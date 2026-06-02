# YOLOv8 / YOLO11 / YOLO12 新结构训练脚本

这个目录用于训练 Ultralytics 新版 YOLO 模型，例如 YOLOv8、YOLO11、YOLO12 等。

## 1. 环境安装

```powershell
E:\YOLO\yolo_new\setup_yolo_new_env.ps1
```

或者手动执行：

```powershell
conda create -n yolo python=3.10 -y
conda activate yolo
pip install ultralytics
```

## 2. 训练

```powershell
E:\YOLO\yolo_new\train_yolo_new.ps1
```

默认训练脚本使用本地权重：

```powershell
$Model = "E:\YOLO\yolo_new\weights\yolo11n.pt"
```

如果想让 Ultralytics 自动下载官方预训练权重，可以把脚本中 `$Model` 改成：

```powershell
$Model = "yolo11n.pt"
```

或者：

```powershell
$Model = "yolov8n.pt"
```

规则很简单：

```text
写模型名称：本地没有时通常会自动联网下载
写本地路径：本地必须真的存在这个 .pt 文件
```

训练结果默认保存到：

```text
E:\YOLO\runs\detect\train
```

如果目录已存在，Ultralytics 可能会自动生成：

```text
E:\YOLO\runs\detect\train2
E:\YOLO\runs\detect\train3
```

## 3. 验证

先把 `val_yolo_new.ps1` 中的 `$Weights` 改成实际训练结果路径，例如：

```powershell
$Weights = "E:\YOLO\runs\detect\train2\weights\best.pt"
```

然后执行：

```powershell
E:\YOLO\yolo_new\val_yolo_new.ps1
```

## 4. 预测

先把 `predict_yolo_new.ps1` 中的 `$Weights` 改成实际训练结果路径，然后执行：

```powershell
E:\YOLO\yolo_new\predict_yolo_new.ps1
```

预测输入目录默认是：

```text
E:\YOLO\merged\test\images
```

## 5. 继续训练

如果训练中断，先把 `resume_yolo_new.ps1` 中的 `$LastWeights` 改成中断训练生成的 `last.pt`：

```powershell
$LastWeights = "E:\YOLO\runs\detect\train2\weights\last.pt"
```

然后执行：

```powershell
E:\YOLO\yolo_new\resume_yolo_new.ps1
```

## 6. 导出 ONNX

先把 `export_yolo_new_onnx.ps1` 中的 `$Weights` 改成实际训练结果路径，然后执行：

```powershell
E:\YOLO\yolo_new\export_yolo_new_onnx.ps1
```

默认导出参数：

```text
format=onnx
imgsz=320
opset=12
simplify=True
device=cpu
```

注意：YOLOv8、YOLO11、YOLO12 等新结构模型的 ONNX 输出格式可能和经典 YOLOv5 不同。部署到 K230 时，需要使用匹配的新结构后处理代码，不能直接套用传统 YOLOv5 的后处理。
