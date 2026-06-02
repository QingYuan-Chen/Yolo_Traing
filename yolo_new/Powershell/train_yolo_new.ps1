$env:YOLO_CONFIG_DIR = "E:\YOLO\yolo_new\ultralytics_config"

conda activate yolo
Set-Location "E:\YOLO"

# Use a local file:
$Model = "E:\YOLO\yolo_new\weights\yolo11n.pt"

# Or use an official model name to auto-download when missing:
# $Model = "yolo11n.pt"
# $Model = "yolov8n.pt"

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
