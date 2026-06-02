# 评估训练好的模型
from pathlib import Path

from ultralytics import YOLO# type: ignore

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    model = YOLO(ROOT / r"runs\detect\train6\weights\best.pt")
    model.predict(ROOT / r"merged\test\images", save=True)


