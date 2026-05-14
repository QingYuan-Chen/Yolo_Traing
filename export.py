#导出onnx模型
from ultralytics import YOLO # type: ignore

if __name__ == "__main__":
    model = YOLO(r"best.pt")
    model.export(format="onnx", simplify=True,imgsz=320,opset=12)
