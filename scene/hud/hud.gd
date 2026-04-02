extends CanvasLayer

signal start_game
signal reset_game

@onready var play_button = $Button
@onready var game_end_ui = $ColorRect
@onready var game_end_label = $ColorRect/Label


func _ready() -> void:
	game_end_ui.hide()
	play_button.show()


func game_end_show_text(value: String):
	game_end_label.text = value
	game_end_ui.show()
	var tween = create_tween()
	tween.tween_property(game_end_ui, "color", Color(), 2)
	tween.tween_callback(reset_game.emit)


func _on_button_pressed() -> void:
	$Button.hide()
	start_game.emit()


func _on_main_game_over() -> void:
	game_end_show_text('Game Over')


func _on_main_game_win() -> void:
	game_end_show_text('You Win!')
