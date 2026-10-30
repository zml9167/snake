extends Node

const OPTIONS_PATH = "user://options.cfg"

@export var config: GameConfig


func _init() -> void:
	if config == null:
		config = GameConfig.new()
	load_settings()


func save_settings(columns: int, rows: int) -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("grid", "columns", columns)
	config_file.set_value("grid", "rows", rows)
	config_file.save(OPTIONS_PATH)
	config.grid_columns = clampi(columns, config.grid_columns_min, config.grid_columns_max)
	config.grid_rows = clampi(rows, config.grid_rows_min, config.grid_rows_max)


func load_settings() -> void:
	var config_file = ConfigFile.new()
	var err = config_file.load(OPTIONS_PATH)
	if err == OK:
		# Read the old "colums" key as a fallback so existing settings survive the rename.
		var columns = config_file.get_value(
			"grid",
			"columns",
			config_file.get_value("grid", "colums", config.grid_columns)
		)
		var rows = config_file.get_value("grid", "rows", config.grid_rows)
		config.grid_columns = clampi(int(columns), config.grid_columns_min, config.grid_columns_max)
		config.grid_rows = clampi(int(rows), config.grid_rows_min, config.grid_rows_max)
