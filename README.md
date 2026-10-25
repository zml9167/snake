# Snake Game

A classic Snake game built with Godot 4 and GDScript. The snake and food are rendered with procedural meshes, with configurable grid dimensions and export presets for Windows and Web.

## Features

- Classic Snake gameplay: guide the snake and grow longer by eating food
- Main menu with start, options, and quit actions
- Adjustable grid rows and columns with persistent settings
- Random food placement that avoids the snake
- Boundary collision and end-of-game handling
- Keyboard and controller D-pad support
- Grid layout that adapts to the window size

## Play Online

Play online at: [https://zml9167.github.io/snake/Snake.html](https://zml9167.github.io/snake/Snake.html)

## How to Run

1. Install Godot 4.7 or later
2. Open `project.godot` in the project root with Godot
3. Press **F5** to run the game

## Controls

- **Arrow keys / WASD**: Control the snake's direction
- **Hold Space**: Move faster; release to return to normal speed
- **Controller D-pad**: Control the snake's direction

## Grid Settings

Select **Option** in the main menu to adjust the number of columns and rows independently. Both values can range from 8 to 16. Click **OK** to save the settings.

The configuration is stored in `user://options.cfg` and loaded automatically the next time the game starts.

## Project Structure

```text
snake/
├── autoload/           # Global configuration loading and saving
├── resourse/data/      # Game configuration resources
├── scenes/
│   ├── game/           # Game scene and core gameplay
│   └── main/           # Main menu and options UI
├── scripts/core/       # Grid coordinate conversion helpers
├── export_presets.cfg  # Windows and Web export presets
├── icon.svg            # Game icon
├── project.godot       # Godot project configuration
├── README.md           # English documentation
└── README_zh.md        # Chinese documentation
```

## Exporting

The project includes **Windows Desktop** and **Web** export presets. In Godot, select **Project → Export** to export the game with either preset.

## License

MIT License
