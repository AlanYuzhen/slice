# video_frame_handle
qtopencv视频拆分为图片帧，帧合成视频（mp4，avi）

## 一键装依赖
双击 `setup.bat`（或管理员 PowerShell 跑 `./setup.ps1`），自动装：
Python → aqtinstall → Qt 5.15.2(MSVC2019 64位) → VS Build Tools 2022 → OpenCV 4.10，并自动设置 `OPENCV_DIR` 环境变量。第一次会下载几个 GB。

## 总入口
程序启动后先打菜单：
```
1. 打开图形界面程序 (Qt 窗口)
2. 命令行拆帧菜单
   （自定义时间段拆帧 / 等长分段拆帧 / 截取单帧 / 图片合成视频）
0. 退出
```
- `main.cpp`：总入口菜单。
- `gui_main.cpp`：原 Qt 图形界面（satellite_video 主窗 + Frame_Handle_Form 四个模式）。
- `cli_menu.cpp`：命令行版四个拆帧模式，和 GUI 里一一对应。
- 快捷参数：`video_handel.exe --gui` 直接开窗口；`video_handel.exe --cli` 直接进命令行菜单。

编译：用 Qt Creator 打开 `video_handel.pro`，选 MSVC2019 64-bit Kit，构建运行。


拆帧分为三种模式：

 - 自定义拆帧（指定开始时刻和结束时刻，并拆分为图片帧）
 - 等长拆帧   （间隔一定时长，将每段时长视频帧进行拆分）
 - 截取单帧 （截取某个时刻的画面帧）
 - 视频合成 （将某一文件夹下的图片合成为视频支持avi，mp4）

## 一，加载视频
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504161945206.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4NDQxNjky,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504161957928.gif)
## 二，自定义拆帧
![帧合成视频](https://img-blog.csdnimg.cn/20200504155215978.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4NDQxNjky,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504162035441.gif)
## 三，等时长拆帧

![等时长拆帧](https://img-blog.csdnimg.cn/20200504155150973.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4NDQxNjky,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504162114639.gif)
## 四，截取单帧
![截取单帧](https://img-blog.csdnimg.cn/20200504155152545.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4NDQxNjky,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504162131657.gif)
## 五，帧合成视频

![自定义时长拆帧](https://img-blog.csdnimg.cn/20200504155200606.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4NDQxNjky,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504162635130.gif)
