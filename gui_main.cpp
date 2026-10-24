// gui_main.cpp —— 启动 Qt 图形界面（原 main.cpp 的内容，改成函数供总入口调用）
#include <QApplication>
#include "satellite_video.h"

int run_gui(int argc, char *argv[])
{
    QApplication a(argc, argv);
    satellite_video video_frme;
    video_frme.show();
    return a.exec();
}
