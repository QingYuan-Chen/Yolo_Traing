# 定制自己的模型，推荐使用5,8,11,12
from ultralytics import YOLO

if __name__ == "__main__":
    model = YOLO(r"weights\yolov12\yolo12n.pt")
    model.train(data="data.yaml", # 教程中提到了这个文件的编写方式
                epochs=200, # 训练多少轮，每一轮指的是让模型看一遍所有的训练集
                batch=32, # 每次让模型看到多少个样本，电脑性能差的记得降低此数值
                workers=0 # 数据处理线程数，电脑性能差的记得降低此数值，写0也可以，表示不用多线程
                )

