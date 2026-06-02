conda activate yolov5gpu128
Set-Location "E:\YOLO\yolov5_train\yolov5"

python export.py `
  --weights "E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.pt" `
  --img 320 `
  --include onnx `
  --opset 11 `
  --simplify `
  --device cpu
