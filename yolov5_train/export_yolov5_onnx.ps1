# 激活特定的 yolov5 虚拟环境并切换至项目代码目录
conda activate yolov5gpu128
Set-Location "E:\YOLO\yolov5_train\yolov5"

# 运行导出脚本，转换 PyTorch(.pt) 模型为特定格式 (如 ONNX)
# 参数说明:
# --weights: 填写训练好的 best.pt 权重路径
# --img 320: 导出模型要求的输入分辨率
# --include onnx: 指定要导出的目标格式为 ONNX 格式
# --opset 11: ONNX 算子集(opset)版本限制为 11, 很多推理硬件框架兼容该版本
# --simplify: 使用 onnxsim 简化导出的模型图结构
# --device cpu: 强制使用 CPU 进行模型导出流程
python export.py `
  --weights "E:\YOLO\yolov5_train\yolov5\runs\train\exp2\weights\best.pt" `
  --img 320 `
  --include onnx `
  --opset 11 `
  --simplify `
  --device cpu
