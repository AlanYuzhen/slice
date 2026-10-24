// cli_main.cpp —— 控制台总入口（不需要 Qt，只依赖 OpenCV）
// 编译示例（MinGW / 任意带 OpenCV 的 g++）：
//   g++ cli_main.cpp -o slice_cli.exe -I"<opencv>/include" -L"<opencv>/x86/mingw/lib" -lopencv_core -lopencv_imgcodecs -lopencv_videoio -lopencv_highgui
//
// 菜单：
//   1 = 自定义时间段拆帧（开始/结束毫秒，把这段里每帧存成图片）
//   2 = 等长分段拆帧（每隔 N 毫秒一个子文件夹）
//   3 = 截取单帧（按帧号取一张图）
//   4 = 图片序列合成视频
//   0 = 退出

#include <opencv2/opencv.hpp>
#include <filesystem>
#include <iostream>
#include <string>

namespace fs = std::filesystem;
using namespace cv;

static void pause() {
    std::cout << "\n按回车返回菜单...";
    std::cin.ignore(1024, '\n');
    std::cin.get();
}

// 1. 自定义时间段拆帧
static void mode_extract_range() {
    std::string video, outdir;
    double start_ms, stop_ms;
    std::cout << "视频路径: ";       std::cin >> video;
    std::cout << "保存目录: ";       std::cin >> outdir;
    std::cout << "开始时间(毫秒): ";  std::cin >> start_ms;
    std::cout << "结束时间(毫秒): ";  std::cin >> stop_ms;

    VideoCapture cap(video);
    if (!cap.isOpened()) { std::cout << "打不开视频\n"; return; }

    fs::create_directories(outdir);
    cap.set(CAP_PROP_POS_MSEC, start_ms);

    Mat frame;
    int idx = 0;
    while (cap.read(frame)) {
        double t = cap.get(CAP_PROP_POS_MSEC);
        if (t >= stop_ms) break;
        char name[256];
        snprintf(name, sizeof(name), "%s/%06d.jpg", outdir.c_str(), idx++);
        imwrite(name, frame);
    }
    std::cout << "完成，共保存 " << idx << " 帧到 " << outdir << "\n";
}

// 2. 等长分段拆帧：每 interval_ms 毫秒一个子文件夹
static void mode_split_by_interval() {
    std::string video, outdir;
    double interval_ms;
    std::cout << "视频路径: ";        std::cin >> video;
    std::cout << "保存目录: ";        std::cin >> outdir;
    std::cout << "分段间隔(毫秒): ";  std::cin >> interval_ms;

    VideoCapture cap(video);
    if (!cap.isOpened()) { std::cout << "打不开视频\n"; return; }

    Mat frame;
    int sub = -1, saved = 0;
    while (cap.read(frame)) {
        double t = cap.get(CAP_PROP_POS_MSEC);
        int cur = (int)(t / interval_ms);
        if (cur != sub) {           // 进入新一段，换子文件夹
            sub = cur;
            fs::create_directories(outdir + "/" + std::to_string(sub));
        }
        char name[256];
        snprintf(name, sizeof(name), "%s/%d/%06d.jpg", outdir.c_str(), sub, saved);
        imwrite(name, frame);
        saved++;
    }
    std::cout << "完成，共 " << saved << " 帧，按 " << interval_ms
              << "ms 分段存到 " << outdir << "\n";
}

// 3. 截取单帧
static void mode_grab_one() {
    std::string video, outimg;
    int frame_idx;
    std::cout << "视频路径: ";      std::cin >> video;
    std::cout << "帧号(从0开始): ";  std::cin >> frame_idx;
    std::cout << "保存图片路径: ";  std::cin >> outimg;

    VideoCapture cap(video);
    if (!cap.isOpened()) { std::cout << "打不开视频\n"; return; }
    cap.set(CAP_PROP_POS_FRAMES, frame_idx);
    Mat frame;
    if (!cap.read(frame)) { std::cout << "读不到这一帧\n"; return; }
    imwrite(outimg, frame);
    std::cout << "已保存第 " << frame_idx << " 帧到 " << outimg << "\n";
}

// 4. 图片序列合成视频
static void mode_pack_video() {
    std::string imgdir, mask, outvideo;
    double fps;
    std::cout << "图片目录(如 D:/frames): ";  std::cin >> imgdir;
    std::cout << "文件名通配(如 %06d.jpg): "; std::cin >> mask;
    std::cout << "输出视频路径(如 out.mp4): "; std::cin >> outvideo;
    std::cout << "帧率: ";                     std::cin >> fps;

    // OpenCV 用 printf 风格模板读图序列，例如 D:/frames/%06d.jpg 对应 000000.jpg...
    std::string pattern = imgdir + "/" + mask;
    VideoCapture seq(pattern);
    if (!seq.isOpened()) { std::cout << "打不开图片序列，检查路径和通配符\n"; return; }

    Mat src;
    seq >> src;
    if (src.empty()) { std::cout << "第一张图就是空的\n"; return; }

    int fourcc = VideoWriter::fourcc('m', 'p', '4', 'v');
    VideoWriter writer(outvideo, fourcc, fps, src.size(), true);
    if (!writer.isOpened()) { std::cout << "VideoWriter 打开失败\n"; return; }

    int n = 1;
    writer.write(src);
    while (seq.read(src)) { writer.write(src); n++; }
    writer.release();
    std::cout << "完成，共写入 " << n << " 帧到 " << outvideo << "\n";
}

int main() {
    setlocale(LC_ALL, "");
    while (true) {
        std::cout << "\n========= 视频拆帧工具 =========\n"
                  << "1. 自定义时间段拆帧\n"
                  << "2. 等长分段拆帧\n"
                  << "3. 截取单帧\n"
                  << "4. 图片序列合成视频\n"
                  << "0. 退出\n"
                  << "请选择: ";
        int op;
        if (!(std::cin >> op)) break;
        try {
            switch (op) {
                case 1: mode_extract_range(); break;
                case 2: mode_split_by_interval(); break;
                case 3: mode_grab_one(); break;
                case 4: mode_pack_video(); break;
                case 0: return 0;
                default: std::cout << "没有这个选项\n";
            }
        } catch (const std::exception& e) {
            std::cout << "出错: " << e.what() << "\n";
        }
        pause();
    }
    return 0;
}
