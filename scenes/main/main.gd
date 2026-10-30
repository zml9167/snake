extends Control

@export var config: GameConfig

@onready var options: VBoxContainer = $Options
@onready var button_group: VBoxContainer = $ButtonGroup
@onready var start: Button = $ButtonGroup/Start


func _ready() -> void:
	start.grab_focus()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_option_pressed() -> void:
	button_group.hide()
	options.show()


func _on_options_options_hide() -> void:
	options.hide()
	button_group.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
