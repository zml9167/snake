extends Node

const OPTIONS_PATH = "user://options.cfg"

@export var config: GameConfig


func _ready() -> void:
	load_settings()


func save_settings(colums: int, rows: int):
	var config_file = ConfigFile.new()
	config_file.set_value("grid", "colums", colums)
	config_file.set_value("grid", "rows", rows)
	config_file.save(OPTIONS_PATH)
	config.grid_colums = colums
	config.grid_rows = rows


func load_settings():
	var config_file = ConfigFile.new()
	var err = config_file.load(OPTIONS_PATH)
	if err == OK:
		config.grid_colums = config_file.get_value("grid", "colums", config.grid_colums)
		config.grid_rows = config_file.get_value("grid", "rows", config.grid_rows)
