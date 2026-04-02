extends Node

signal game_over
signal game_win

var snake_size := 20
var snake_size_half = snake_size / 2.0
var grid: Vector2i
var max_len: int
var grow_up_num := 1

@onready var snake := $Snake
@onready var food := $Food
@onready var viewport_size := get_viewport().get_visible_rect().size


func _ready() -> void:
	snake.size = snake_size
	var init_direction = snake.SnakeDirection.RIGHT
	var init_position = viewport_size / 2 + Vector2(snake_size_half, snake_size_half - snake_size)
	snake.spawn(init_direction, init_position)
	grid = viewport_size / snake_size
	max_len = grid.x * grid.y


func position2index(pos: Vector2) -> int:
	var res = Vector2i(pos / snake_size)
	var index = res.y * grid.x + res.x
	return index


func index2position(index: int):
	var row = int(index / grid.x)
	var col = index % grid.x
	var res = Vector2(col + 0.5, row + 0.5) * snake_size
	return res


func spawn_food():
	var idle_arr = PackedInt32Array(range(max_len))
	if not idle_arr:
		return
	for pos in snake.positions:
		idle_arr.erase(position2index(pos))
	var random_index = randi() % len(idle_arr)
	food.position = index2position(idle_arr[random_index])


func _on_snake_move_done(value: Vector2) -> void:
	if snake.direction == Vector2.LEFT:
		if value.x - snake_size_half < 0:
			game_over.emit()
	elif snake.direction == Vector2.RIGHT:
		if value.x + snake_size_half > viewport_size.x:
			game_over.emit()
	elif snake.direction == Vector2.UP:
		if value.y - snake_size_half < 0:
			game_over.emit()
	elif snake.direction == Vector2.DOWN:
		if value.y + snake_size_half > viewport_size.y:
			game_over.emit()
	if is_equal_approx(value.x, food.position.x) && is_equal_approx(value.y, food.position.y):
		snake.grow_up(grow_up_num)
		if len(snake.nodes) > max_len:
			game_win.emit()
			return
		spawn_food()


func _on_snake_collision() -> void:
	game_over.emit()


func _on_hud_reset_game() -> void:
	get_tree().reload_current_scene()


func _on_hud_start_game() -> void:
	spawn_food()
	food.show()
