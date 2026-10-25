# 贪吃蛇游戏

使用 Godot 4 和 GDScript 实现的经典贪吃蛇游戏。蛇和食物通过程序化网格绘制，支持自定义棋盘大小，并提供 Windows 桌面版和 Web 版导出预设。

## 功能特性

- 经典贪吃蛇玩法：控制蛇移动，吃到食物后变长
- 主菜单：开始游戏、设置和退出
- 可调整棋盘行数和列数，设置会自动保存
- 食物随机生成，并避开蛇身
- 边界碰撞与游戏结束处理
- 支持键盘和手柄方向键
- 棋盘布局随窗口尺寸自适应

## 在线体验

在线体验地址：[https://zml9167.github.io/snake/Snake.html](https://zml9167.github.io/snake/Snake.html)

## 如何运行

1. 安装 Godot 4.7 或更高版本
2. 使用 Godot 打开项目根目录中的 `project.godot`
3. 按 **F5** 运行游戏

## 操作方式

- **方向键 / WASD**：控制蛇的移动方向
- **按住空格键**：加速移动，松开后恢复常速
- **手柄方向键**：控制蛇的移动方向

## 棋盘设置

在主菜单中选择 **Option**，可以分别调整棋盘的列数和行数，范围均为 8～16。点击 **OK** 后保存设置。

配置保存在 `user://options.cfg`，下次启动游戏时会自动加载。

## 项目结构

```text
snake/
├── autoload/           # 全局配置的加载与保存
├── resourse/data/      # 游戏配置资源
├── scenes/
│   ├── game/           # 游戏场景与核心玩法
│   └── main/           # 主菜单与设置界面
├── scripts/core/       # 网格坐标转换工具
├── export_presets.cfg  # Windows 与 Web 导出预设
├── icon.svg            # 游戏图标
├── project.godot       # Godot 项目配置
├── README.md           # 英文说明文件
└── README_zh.md        # 中文说明文件
```

## 导出

项目已提供 **Windows Desktop** 和 **Web** 导出预设。在 Godot 中选择“项目 → 导出”，即可使用对应预设导出游戏。

## 许可证

MIT 许可证
