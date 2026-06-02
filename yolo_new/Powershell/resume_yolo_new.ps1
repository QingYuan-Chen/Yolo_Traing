# 指定 YOLO 配置缓存目录，避免全局污染
$env:YOLO_CONFIG_DIR = "E:\YOLO\yolo_new\ultralytics_config"

# 激活 yolo 虚拟环境
conda activate yolo
# 切换工作目录到项目根目录
Set-Location "E:\YOLO"

# 将此路径修改为中断训练时保存的最新一次的 last.pt 权重文件路径
$LastWeights = "E:\YOLO\runs\detect\train\weights\last.pt"

# 恢复并继续被中断的模型训练
yolo detect train `
  model="$LastWeights" `
  resume=True
