#-------------------------------------------------
# Project created by QtCreator 2020-05-03T16:01:02
# 总入口工程：main.cpp(菜单) + gui_main.cpp(Qt界面) + cli_menu.cpp(命令行四个模式)
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

# 带控制台窗口，用来打印总入口菜单
CONFIG += console

TARGET = video_handel
TEMPLATE = app

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        main.cpp \
        gui_main.cpp \
        cli_menu.cpp \
        frame_handle_form.cpp \
        satellite_video.cpp

HEADERS += \
        frame_handle_form.h \
        satellite_video.h \
        cli_menu.h

FORMS += \
        frame_handle_form.ui \
        satellite_video.ui

RESOURCES += \
    image.qrc

# OpenCV 根目录由环境变量 OPENCV_DIR 指定（setup.ps1 自动设置）。
# 用官方 Windows 预编译包时，链接 opencv_world<版本>.lib；
# 如果是自己编的分体库，把下面 LIBS 改回原来的分体写法。
OPENCV_PATH = $$(OPENCV_DIR)
isEmpty(OPENCV_PATH) {
    message("警告：未检测到 OPENCV_DIR 环境变量，请先运行 setup.ps1")
} else {
    INCLUDEPATH += $$OPENCV_PATH/include
    LIBS += -L$$OPENCV_PATH/x64/vc16/lib -lopencv_world4100
}
