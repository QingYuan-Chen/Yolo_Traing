# 定制自己的新版 YOLO 模型，例如 YOLOv8、YOLO11、YOLO12
from pathlib import Path

from ultralytics import YOLO # type: ignore

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    model = YOLO(ROOT / r"yolo_new\weights\yolo11n.pt")
    model.train(data=ROOT / r"yolo_new\data.yaml",
                epochs=200, # 训练多少轮，每一轮指的是让模型看一遍所有的训练集
                batch=16, # 每次让模型看到多少个样本，电脑性能差的记得降低此数值
                workers=0 # 数据处理线程数，电脑性能差的记得降低此数值，写0也可以，表示不用多线程
                ,imgsz=320 # 输入图片的尺寸，推荐使用320,640,1280等倍数的数值，过大可能会导致显存不足，过小可能会影响模型性能
                )

