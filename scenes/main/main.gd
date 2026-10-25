extends Node

@export var config: GameConfig

@onready var button_group: VBoxContainer = $Control/ButtonGroup
@onready var options: VBoxContainer = $Control/Options


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
