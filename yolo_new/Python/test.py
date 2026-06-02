# 评估训练好的模型
from pathlib import Path

from ultralytics import YOLO# type: ignore

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    model = YOLO(ROOT / r"runs\detect\train2\weights\best.pt")
    model.val(data=ROOT / r"yolo_new\data.yaml", # 修改确切的数据集配置路径
                split="test"
                )
