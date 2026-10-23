#!/usr/bin/env python3
"""
slice — decode a video into a frame sequence, or pack a frame sequence back into a video.

Examples:
  # extract every frame
  python slice.py video.mp4 -o frames/

  # sample 1 frame per second
  python slice.py video.mp4 -o frames/ --fps 1

  # extract a time window: start at 00:01.5, for 5 seconds
  python slice.py video.mp4 -o frames/ --start 1.5 --duration 5

  # pack frames/ back into a 30 fps mp4
  python slice.py --pack frames/ -o out.mp4 --fps 30
"""
import argparse
import os
import sys

import cv2


def to_seconds(value):
    """Accept seconds (float) or HH:MM:SS / MM:SS."""
    if value is None:
        return 0.0
    if isinstance(value, (int, float)):
        return float(value)
    parts = str(value).split(":")
    parts = [float(p) for p in parts]
    sec = 0.0
    for p in parts:
        sec = sec * 60 + p
    return sec


def extract(args):
    cap = cv2.VideoCapture(args.input)
    if not cap.isOpened():
        sys.exit(f"[slice] cannot open video: {args.input}")

    src_fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    os.makedirs(args.output, exist_ok=True)

    step = max(1, round(src_fps / args.fps)) if args.fps else 1
    start_frame = int(to_seconds(args.start) * src_fps)
    if args.duration:
        end_frame = min(total, start_frame + int(args.duration * src_fps))
    else:
        end_frame = total

    cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

    idx = start_frame
    saved = 0
    while idx < end_frame:
        ok, frame = cap.read()
        if not ok:
            break
        if (idx - start_frame) % step == 0:
            name = os.path.join(args.output, f"{saved:06d}.jpg")
            cv2.imwrite(name, frame)
            saved += 1
        idx += 1

    cap.release()
    print(f"[slice] done: {saved} frames -> {args.output} "
          f"(source {src_fps:.2f} fps, sampled every {step} frame(s))")


def pack(args):
    exts = (".jpg", ".jpeg", ".png")
    files = sorted(
        f for f in os.listdir(args.input)
        if f.lower().endswith(exts)
    )
    if not files:
        sys.exit(f"[slice] no images in: {args.input}")

    first = cv2.imread(os.path.join(args.input, files[0]))
    if first is None:
        sys.exit(f"[slice] cannot read first frame: {files[0]}")
    h, w = first.shape[:2]

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(args.output, fourcc, args.fps, (w, h))
    if not writer.isOpened():
        sys.exit(f"[slice] cannot open writer for: {args.output}")

    written = 0
    for f in files:
        img = cv2.imread(os.path.join(args.input, f))
        if img is None:
            continue
        writer.write(img)
        written += 1

    writer.release()
    print(f"[slice] done: {written} frames -> {args.output} ({w}x{h}, {args.fps} fps)")


def main():
    p = argparse.ArgumentParser(description="slice: video <-> frame sequence")
    p.add_argument("input", help="input video file, or frames directory when using --pack")
    p.add_argument("-o", "--output", required=True,
                   help="output directory (extract) or output video file (pack)")
    p.add_argument("--fps", type=float, default=None,
                   help="extract: sampled frames per second (default: every frame); "
                        "pack: output fps (default 30)")
    p.add_argument("--start", default=None, help="extract: start time, seconds or HH:MM:SS")
    p.add_argument("--duration", type=float, default=None,
                   help="extract: duration in seconds")
    p.add_argument("--pack", action="store_true",
                   help="pack a frames directory back into a video")
    args = p.parse_args()

    if args.pack:
        args.fps = args.fps or 30.0
        pack(args)
    else:
        extract(args)


if __name__ == "__main__":
    main()
