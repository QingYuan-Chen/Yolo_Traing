# 定制自己的模型，推荐使用5,8,11,12
from pathlib import Path

from ultralytics import YOLO # type: ignore

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    # 这里的路径改成你上次因中断而生成的最后一次权重路径
    # 比如: model = YOLO(r"runs\detect\train\weights\last.pt") 
    model = YOLO(ROOT / r"runs\detect\train3\weights\last.pt")
    # 接着训练的核心参数是 resume=True，其他参数会自动从中断时的配置读取
    model.train(resume=True)
