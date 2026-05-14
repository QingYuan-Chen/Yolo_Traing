# 评估训练好的模型
from ultralytics import YOLO# type: ignore

if __name__ == "__main__":
    model = YOLO(r"runs\detect\train6\weights\best.pt")
    model.val(data="data.yaml", # 教程中提到了这个文件的编写方式
                split="test"
                )
