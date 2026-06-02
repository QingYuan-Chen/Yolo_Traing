$env:YOLO_CONFIG_DIR = "E:\YOLO\yolov5_train\ultralytics_config"

conda activate yolov5gpu128
Set-Location "E:\YOLO\yolov5_train\yolov5"

python train.py `
  --img 320 `
  --batch-size 16 `
  --epochs 200 `
  --data "E:\YOLO\yolov5_train\data.yaml" `
  --weights "E:\YOLO\Model_Traning\weights\yolov5\yolov5n.pt" `
  --workers 0 `
  --device 0
