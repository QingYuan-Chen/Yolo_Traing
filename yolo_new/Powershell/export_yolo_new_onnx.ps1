# 指定 YOLO 配置缓存目录，避免全局污染
$env:YOLO_CONFIG_DIR = "E:\YOLO\yolo_new\ultralytics_config"

# 激活 yolo 虚拟环境
conda activate yolo
# 切换工作目录到项目根目录
Set-Location "E:\YOLO"

# 将此路径修改为你最新一次训练所得的 best.pt 权重文件路径
$Weights = "E:\YOLO\runs\detect\train\weights\best.pt"

# 执行模型导出，将 PyTorch 模型 (.pt) 导出为 ONNX 格式
yolo export `
  model="$Weights" `
  format=onnx `
  imgsz=320 ` # 推理时计划使用的输入图像尺寸，建议为 32 的整数倍。
  opset=12 ` # ONNX 算子集(opset)版本。12 对各类推理框架兼容性较好。
  simplify=True `
  device=cpu
