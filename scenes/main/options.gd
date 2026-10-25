extends VBoxContainer

signal options_hide

@onready var colums: Label = $GridColums/Colums
@onready var rows: Label = $GridRows/Rows
@onready var colum_h_slider: HSlider = $GridColums/ColumHSlider
@onready var row_h_slider: HSlider = $GridRows/RowHSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colum_h_slider.value = Global.config.grid_colums
	colum_h_slider.min_value = Global.config.grid_colums_min
	colum_h_slider.max_value = Global.config.grid_colums_max
	set_colums(Global.config.grid_colums)
	row_h_slider.value = Global.config.grid_rows
	row_h_slider.min_value = Global.config.grid_rows_min
	row_h_slider.max_value = Global.config.grid_rows_max
	set_rows(Global.config.grid_rows)


func set_colums(value: int):
	colums.text = str(value)


func set_rows(value: int):
	rows.text = str(value)


func _on_colum_h_slider_value_changed(value: float) -> void:
	set_colums(int(value))


func _on_row_h_slider_value_changed(value: float) -> void:
	set_rows(int(value))


func _on_ok_pressed() -> void:
	Global.save_settings(colum_h_slider.value, row_h_slider.value)
	options_hide.emit()
