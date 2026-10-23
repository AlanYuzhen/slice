# slice

一个把视频逐帧拆成图片序列的小工具，支持任意帧率抽帧（全量 / 按秒 / 按时间区间），也支持把编号图片重新编码回视频。底层走 OpenCV VideoCapture，适合做视觉数据集、机器人视觉算法离线调试。

## 安装

```bash
pip install -r requirements.txt
```

## 用法

把视频拆成一帧帧图片：

```bash
# 每一帧都拆出来
python slice.py video.mp4 -o frames/

# 每秒抽 1 帧
python slice.py video.mp4 -o frames/ --fps 1

# 从 00:01.5 开始，往后抽 5 秒
python slice.py video.mp4 -o frames/ --start 1.5 --duration 5
```

把图片序列打包回视频：

```bash
python slice.py --pack frames/ -o out.mp4 --fps 30
```

## 参数

| 参数 | 说明 |
|---|---|
| `input` | 输入视频文件；加 `--pack` 时为图片目录 |
| `-o, --output` | 输出目录（拆帧）或输出视频文件（打包） |
| `--fps` | 拆帧：每秒采样帧数，缺省 = 每一帧；打包：输出帧率，缺省 30 |
| `--start` | 拆帧起始时间，秒数或 `HH:MM:SS` |
| `--duration` | 拆帧时长（秒） |
| `--pack` | 打包模式：图片序列 → 视频 |

## 输出约定

- 拆帧结果按 `000000.jpg`、`000001.jpg` … 顺序命名，打包时按文件名排序。
