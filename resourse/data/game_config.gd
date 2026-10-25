extends Resource

class_name GameConfig

@export var grid_rows_min: int = 8
@export var grid_rows_max: int = 16
@export_range(8, 16) var grid_rows: int = 8

@export var grid_colums_min: int = 8
@export var grid_colums_max: int = 16
@export_range(8, 16) var grid_colums: int = 8
