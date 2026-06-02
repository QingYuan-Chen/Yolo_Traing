# Traditional YOLOv5 Training

This folder is for traditional YOLOv5 training with the official
`ultralytics/yolov5` repository.

## GPU environment

```powershell
conda activate yolov5gpu128
```

This environment was verified with `torch 2.11.0+cu128` on an
`NVIDIA GeForce RTX 5060 Laptop GPU`.

## Train

```powershell
E:\YOLO\yolov5_train\train_yolov5.ps1
```

The trained weights will be saved under:

```text
E:\YOLO\yolov5_train\yolov5\runs\train\exp*\weights
```

## Export ONNX

```powershell
E:\YOLO\yolov5_train\export_yolov5_onnx.ps1
```

For K230 conversion, export with `opset 11`, fixed `img 320`, and CPU export.
See `E:\YOLO\README.md` for the complete training, conversion, deployment, and
GitHub push guide.
