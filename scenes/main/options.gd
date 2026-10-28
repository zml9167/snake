extends VBoxContainer

signal options_hide

@onready var columns: Label = $GridColumns/Columns
@onready var rows: Label = $GridRows/Rows
@onready var column_h_slider: HSlider = $GridColumns/ColumnHSlider
@onready var row_h_slider: HSlider = $GridRows/RowHSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	column_h_slider.min_value = Global.config.grid_columns_min
	column_h_slider.max_value = Global.config.grid_columns_max
	column_h_slider.value = clampi(
		Global.config.grid_columns,
		Global.config.grid_columns_min,
		Global.config.grid_columns_max
	)
	set_columns(int(column_h_slider.value))

	row_h_slider.min_value = Global.config.grid_rows_min
	row_h_slider.max_value = Global.config.grid_rows_max
	row_h_slider.value = clampi(
		Global.config.grid_rows,
		Global.config.grid_rows_min,
		Global.config.grid_rows_max
	)
	set_rows(int(row_h_slider.value))


func set_columns(value: int):
	columns.text = str(value)


func set_rows(value: int):
	rows.text = str(value)


func _on_column_h_slider_value_changed(value: float) -> void:
	set_columns(int(value))


func _on_row_h_slider_value_changed(value: float) -> void:
	set_rows(int(value))


func _on_ok_pressed() -> void:
	Global.save_settings(int(column_h_slider.value), int(row_h_slider.value))
	options_hide.emit()
