# 指定 YOLO 配置缓存目录，避免全局污染
$env:YOLO_CONFIG_DIR = "E:\YOLO\yolov5_train\ultralytics_config"

# 激活 yolov5gpu128 虚拟环境并切换工作目录到 yolov5 源码目录
conda activate yolov5gpu128
Set-Location "E:\YOLO\yolov5_train\yolov5"

# 使用 train.py 脚本启动 yolov5 训练
# 参数说明:
# --img 320: 设定输入图像大小
# --batch-size 16: 设置单次训练处理的批次大小
# --epochs 200: 设置总训练轮数
# --data: 指定数据集配置 yaml 文件所在路径
# --weights: 提供初始的预训练权重，加速收敛
# --workers 0: 数据加载的并发工作线程，Windows里设为0防止卡死
# --device 0: 指定使用哪一张 GPU 进行训练 (0 为第一块)
python train.py `
  --img 320 `
  --batch-size 16 `
  --epochs 200 `
  --data "E:\YOLO\yolov5_train\data.yaml" `
  --weights "E:\YOLO\Model_Traning\weights\yolov5\yolov5n.pt" `
  --workers 0 `
  --device 0
