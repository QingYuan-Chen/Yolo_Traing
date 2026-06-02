# 指定 YOLO 配置缓存目录，避免全局污染
$env:YOLO_CONFIG_DIR = "E:\YOLO\yolo_new\ultralytics_config"

# 激活 yolo 虚拟环境
conda activate yolo
# 切换工作目录到项目根目录
Set-Location "E:\YOLO"

# 将此路径修改为你最新一次训练所得的 best.pt 权重文件路径
$Weights = "E:\YOLO\runs\detect\train\weights\best.pt"

# 运行模型预测并保存检测结果图片
yolo detect predict `
  model="$Weights" `
  source="E:\YOLO\merged\test\images" `
  imgsz=320 `
  conf=0.25 `
  device=0 `
  save=True
