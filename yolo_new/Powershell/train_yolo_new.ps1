# 指定 YOLO 配置缓存目录，避免全局污染
$env:YOLO_CONFIG_DIR = "E:\YOLO\yolo_new\ultralytics_config"

# 激活 yolo 虚拟环境
conda activate yolo
# 切换工作目录到项目根目录
Set-Location "E:\YOLO"

# 使用本地的预训练模型文件:
$Model = "E:\YOLO\yolo_new\weights\yolo11n.pt"

# 或者使用官方模型名称(如果没找到将自动下载):
# $Model = "yolo11n.pt"
# $Model = "yolov8n.pt"

# 执行目标检测模型训练
yolo detect train `
  model="$Model" `
  data="E:\YOLO\yolo_new\data.yaml" `
  epochs=200 `
  imgsz=320 `
  batch=16 `
  workers=0 `
  device=0 `
  project="E:\YOLO\runs\detect" `
  name="train"
