#导出onnx模型
from pathlib import Path

from ultralytics import YOLO # type: ignore

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    model = YOLO(ROOT / r"runs\detect\train4\weights\best.pt") #加载训练好的模型
    model.export(format="onnx", simplify=True,imgsz=320,opset=12) #导出onnx模型，simplify=True表示简化模型，imgsz=320表示输入图像大小为320x320，opset=12表示使用ONNX opset版本12
