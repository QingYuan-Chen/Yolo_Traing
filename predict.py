# 评估训练好的模型
from ultralytics import YOLO# type: ignore

if __name__ == "__main__":
    model = YOLO(r"D:\BaiduNetdiskDownload\yoloAll\runs\detect\train6\weights\best.pt")
    model.predict(r"D:\BaiduNetdiskDownload\yoloAll\dataset\test\images", save=True)


