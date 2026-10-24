// main.cpp —— 总入口
// 运行后先打菜单：选 1 进 Qt 图形界面，选 2 进命令行拆帧菜单，选 0 退出。
// 命令行参数快捷方式： 程序名 --gui   直接开图形界面
//                      程序名 --cli   直接进命令行菜单
#include <iostream>
#include <string>

int run_gui(int argc, char *argv[]);   // 来自 gui_main.cpp（Qt 图形界面）
int run_cli_menu();                     // 来自 cli_menu.cpp（命令行四个拆帧模式）

int main(int argc, char *argv[])
{
    // 带参数直接跳，不打菜单
    if (argc > 1) {
        std::string a = argv[1];
        if (a == "--gui") return run_gui(argc, argv);
        if (a == "--cli") return run_cli_menu();
    }

    while (true) {
        std::cout << "\n========= 视频拆帧工具 · 总入口 =========\n"
                  << "1. 打开图形界面程序 (Qt 窗口)\n"
                  << "2. 命令行拆帧菜单\n"
                  << "   （含：自定义时间段拆帧 / 等长分段拆帧 / 截取单帧 / 图片合成视频）\n"
                  << "0. 退出\n"
                  << "请选择: ";
        int op;
        if (!(std::cin >> op)) break;
        if (op == 1)      return run_gui(argc, argv);
        else if (op == 2) { run_cli_menu(); }   // 跑完命令行菜单后回总菜单
        else if (op == 0) break;
        else std::cout << "没有这个选项\n";
    }
    return 0;
}
