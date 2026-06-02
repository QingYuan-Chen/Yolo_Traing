# 树莓派 5 Hailo YOLO 模型转换记录

本文记录当前环境中将 YOLO 的 ONNX 模型转换为 Hailo `.hef` 模型的流程。

## 当前环境

- Windows 用户目录：`C:\Users\MECHREU`
- WSL 发行版：`Ubuntu-22.04`
- Hailo 工作目录：`/home/a/hailo-work`
- Docker 镜像：`hailo8_ai_sw_suite_2025-10:1`
- 容器内挂载目录：`/workspace`
- ONNX 模型：`/workspace/YOLOV8.onnx`
- 校准图片目录：`/workspace/calib_images`
- 目标硬件：`hailo8l`
- 类别数：`1`
- 目标输入尺寸：`320x320`

## 1. 进入 WSL 工作目录

在 Windows PowerShell 中执行：

```powershell
wsl -d Ubuntu-22.04
```

进入 WSL 后：

```bash
cd /home/a/hailo-work
ls -lh
```

确认至少有这些文件：

```text
YOLOV8.onnx
calib_images/
```

## 2. 检查 ONNX 输入尺寸

可以在 Hailo Docker 容器里检查：

```bash
docker run --rm -v /home/a/hailo-work:/workspace hailo8_ai_sw_suite_2025-10:1 bash -lc '
python - <<PY
import onnx
model = onnx.load("/workspace/YOLOV8.onnx")
for i in model.graph.input:
    dims = [d.dim_value or d.dim_param for d in i.type.tensor_type.shape.dim]
    print(i.name, dims)
PY
'
```

本次使用的 ONNX 输入是：

```text
images [1, 3, 320, 320]
```

## 3. 准备 NMS 320 配置文件

创建 `/home/a/hailo-work/yolov8n_nms_config_320.json`：

```bash
cat > /home/a/hailo-work/yolov8n_nms_config_320.json <<'EOF'
{
  "nms_scores_th": 0.2,
  "nms_iou_th": 0.7,
  "image_dims": [320, 320],
  "max_proposals_per_class": 100,
  "classes": 1,
  "regression_length": 16,
  "background_removal": false,
  "background_removal_index": 0,
  "bbox_decoders": [
    {
      "name": "bbox_decoder41",
      "stride": 8,
      "reg_layer": "conv41",
      "cls_layer": "conv42"
    },
    {
      "name": "bbox_decoder52",
      "stride": 16,
      "reg_layer": "conv52",
      "cls_layer": "conv53"
    },
    {
      "name": "bbox_decoder62",
      "stride": 32,
      "reg_layer": "conv62",
      "cls_layer": "conv63"
    }
  ]
}
EOF
```

关键点是：

```json
"image_dims": [320, 320]
```

否则会出现输入是 320，但 NMS 仍按 640 计算，导致检测框偏移。

## 4. 准备 model script

创建 `/home/a/hailo-work/yolov8n_320.alls`：

```bash
cat > /home/a/hailo-work/yolov8n_320.alls <<'EOF'
normalization1 = normalization([0.0, 0.0, 0.0], [255.0, 255.0, 255.0])
change_output_activation(conv42, sigmoid)
change_output_activation(conv53, sigmoid)
change_output_activation(conv63, sigmoid)
nms_postprocess("/workspace/yolov8n_nms_config_320.json", meta_arch=yolov8, engine=cpu)
performance_param(compiler_optimization_level=max)
allocator_param(width_splitter_defuse=disabled)
EOF
```

说明：

- `nms_postprocess(...)` 使用自定义的 320 NMS 配置。
- `performance_param(compiler_optimization_level=max)` 用于性能编译，最终本次编译得到 `2 contexts`。
- 不要同时加入手动 `resources_param(...)`，否则可能报错：

```text
Performance Flow requires automatic resource utilization
```

## 5. 开始编译 HEF

在 WSL 中执行：

```bash
cd /home/a/hailo-work

rm -f yolov8n.hef yolov8n.har #去除之前编译的残留,防止干扰

docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  bash -lc '
    cd /workspace &&
    hailomz compile yolov8n \
      --ckpt /workspace/YOLOV8.onnx \
      --calib-path /workspace/calib_images \
      --hw-arch hailo8l \
      --classes 1 \
      --model-script /workspace/yolov8n_320.alls
  '
```

编译成功时会看到：

```text
Successful Compilation
HEF file written to yolov8n.hef
```

## 6. 保存为清晰文件名

```bash
cd /home/a/hailo-work

cp -f yolov8n.hef yolov8n-320-nms320-performance.hef
cp -f yolov8n.har yolov8n-320-nms320-performance.har
```

## 7. 验证 HEF 是否正确

执行：

```bash
docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  hailortcli parse-hef /workspace/yolov8n-320-nms320-performance.hef
```

本次验证结果：

```text
Architecture HEF was compiled for: HAILO8L
Network group name: yolov8n, Multi Context - Number of contexts: 2
Input  yolov8n/input_layer1 UINT8, NHWC(320x320x3)
Output yolov8n/yolov8_nms_postprocess FLOAT32, HAILO NMS BY CLASS
Classes: 1
Image height: 320
Image width: 320
```

重点确认这几项：

```text
Number of contexts: 2
Input: 320x320
Image height: 320
Image width: 320
```

## 8. 复制到 Windows 桌面

在 WSL 中执行：

```bash
cp -f /home/a/hailo-work/yolov8n-320-nms320-performance.hef \
  /mnt/c/Users/MECHREU/Desktop/
```

最终桌面文件：

```text
C:\Users\MECHREU\Desktop\yolov8n-320-nms320-performance.hef
```

## 9. 输入 640 的 HEF 转换流程

如果 ONNX 模型本身是 640 输入，例如：

```text
images [1, 3, 640, 640]
```

则 HEF 内部的 NMS 也应该保持 640：

```text
Image height: 640
Image width: 640
```

### 方法 A：使用 Hailo Model Zoo 默认 640 配置

如果使用的是 `yolov8n` 官方默认配置，Hailo Model Zoo 默认的 `yolov8n_nms_config.json` 就是 640。可以直接编译：

```bash
cd /home/a/hailo-work

rm -f yolov8n.hef yolov8n.har

docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  bash -lc '
    cd /workspace &&
    hailomz compile yolov8n \
      --ckpt /workspace/YOLOV8-640.onnx \
      --calib-path /workspace/calib_images \
      --hw-arch hailo8l \
      --classes 1 \
      --performance
  '
```

保存为清晰文件名：

```bash
cd /home/a/hailo-work

cp -f yolov8n.hef yolov8n-640.hef
cp -f yolov8n.har yolov8n-640.har
```

复制到 Windows 桌面：

```bash
cp -f /home/a/hailo-work/yolov8n-640.hef \
  /mnt/c/Users/MECHREU/Desktop/
```

### 方法 B：显式指定 NMS 640 配置

如果想和 320 流程一样显式控制 NMS 配置，可以创建 `/home/a/hailo-work/yolov8n_nms_config_640.json`：

```bash
cat > /home/a/hailo-work/yolov8n_nms_config_640.json <<'EOF'
{
  "nms_scores_th": 0.2,
  "nms_iou_th": 0.7,
  "image_dims": [640, 640],
  "max_proposals_per_class": 100,
  "classes": 1,
  "regression_length": 16,
  "background_removal": false,
  "background_removal_index": 0,
  "bbox_decoders": [
    {
      "name": "bbox_decoder41",
      "stride": 8,
      "reg_layer": "conv41",
      "cls_layer": "conv42"
    },
    {
      "name": "bbox_decoder52",
      "stride": 16,
      "reg_layer": "conv52",
      "cls_layer": "conv53"
    },
    {
      "name": "bbox_decoder62",
      "stride": 32,
      "reg_layer": "conv62",
      "cls_layer": "conv63"
    }
  ]
}
EOF
```

创建 `/home/a/hailo-work/yolov8n_640.alls`：

```bash
cat > /home/a/hailo-work/yolov8n_640.alls <<'EOF'
normalization1 = normalization([0.0, 0.0, 0.0], [255.0, 255.0, 255.0])
change_output_activation(conv42, sigmoid)
change_output_activation(conv53, sigmoid)
change_output_activation(conv63, sigmoid)
nms_postprocess("/workspace/yolov8n_nms_config_640.json", meta_arch=yolov8, engine=cpu)
performance_param(compiler_optimization_level=max)
allocator_param(width_splitter_defuse=disabled)
EOF
```

然后编译：

```bash
cd /home/a/hailo-work

rm -f yolov8n.hef yolov8n.har

docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  bash -lc '
    cd /workspace &&
    hailomz compile yolov8n \
      --ckpt /workspace/YOLOV8-640.onnx \
      --calib-path /workspace/calib_images \
      --hw-arch hailo8l \
      --classes 1 \
      --model-script /workspace/yolov8n_640.alls
  '
```

保存并复制：

```bash
cd /home/a/hailo-work

cp -f yolov8n.hef yolov8n-640-nms640-performance.hef
cp -f yolov8n.har yolov8n-640-nms640-performance.har

cp -f /home/a/hailo-work/yolov8n-640-nms640-performance.hef \
  /mnt/c/Users/MECHREU/Desktop/
```

### 验证 640 HEF

执行：

```bash
docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  hailortcli parse-hef /workspace/yolov8n-640-nms640-performance.hef
```

需要确认：

```text
Input  yolov8n/input_layer1 UINT8, NHWC(640x640x3)
Image height: 640
Image width: 640
```

如果是方法 A 保存的 `yolov8n-640.hef`，则验证命令改成：

```bash
docker run --rm \
  -v /home/a/hailo-work:/workspace \
  hailo8_ai_sw_suite_2025-10:1 \
  hailortcli parse-hef /workspace/yolov8n-640.hef
```

## 常见问题

### 输入是 320，但检测框偏移

通常是 HEF 内部 NMS 配置仍然是 640：

```text
Input: 320x320
Image height: 640
Image width: 640
```

解决方式是重新编译，并确保 NMS 配置文件里：

```json
"image_dims": [320, 320]
```

### 为什么会变成 3 contexts

如果只使用自定义 NMS `.alls`，但没有性能参数，Hailo 编译器可能用较保守的资源分配，最终得到 `3 contexts`。

本次为了得到 `2 contexts`，在 `.alls` 中加入：

```text
performance_param(compiler_optimization_level=max)
```

### performance_param 和 resources_param 不能一起用

如果同时写：

```text
performance_param(compiler_optimization_level=max)
resources_param(...)
```

可能报错：

```text
Performance Flow requires automatic resource utilization
```

解决方式：删除 `resources_param(...)`，让 performance flow 自动分配资源。

### Docker 提示没有 NVIDIA Driver

日志里可能出现：

```text
WARNING: The NVIDIA Driver was not detected. GPU functionality will not be available.
No GPU chosen and no suitable GPU found, falling back to CPU.
```

这表示当前容器没有使用 GPU。编译仍然可以跑，只是优化或编译速度可能受影响。
