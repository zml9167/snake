extends Node

signal move_done(value: Vector2)
signal collision

enum SnakeDirection {UP, RIGHT, DOWN, LEFT}

@export var init_length := 1
@export var size := 20
@export var speed := 100.0
@export var self_collision := true

var positions := PackedVector2Array([])
var nodes := []
var direction := Vector2.RIGHT
var next_direction := Vector2.RIGHT
var header := preload("res://scene/snake/header.tscn")
var body := preload("res://scene/snake/body.tscn")


func _process(_delta: float) -> void:
	var new_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not new_direction:
		normal_speed()
		return
	if new_direction == direction:
		speed_up()
	else:
		normal_speed()
	next_direction = new_direction
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		next_direction = Vector2.DOWN
	elif event.is_action_pressed("move_up"):
		next_direction = Vector2.UP
	if event.is_action_pressed("move_left"):
		next_direction = Vector2.LEFT
	elif event.is_action_pressed("move_right"):
		next_direction = Vector2.RIGHT


func spawn_body(pos: Vector2):
	var body_instance = body.instantiate()
	body_instance.size = size
	body_instance.position = pos
	add_child(body_instance)
	nodes.append(body_instance)
	positions.append(pos)


func spawn(init_direction: SnakeDirection, init_position: Vector2):
	var header_instance = header.instantiate()
	header_instance.position = init_position
	header_instance.size = size
	add_child(header_instance)
	positions.append(init_position)
	nodes.append(header_instance)
	if init_direction == SnakeDirection.UP:
		direction = Vector2.UP
	elif init_direction == SnakeDirection.DOWN:
		direction = Vector2.DOWN
	elif init_direction == SnakeDirection.LEFT:
		direction = Vector2.LEFT
	elif init_direction == SnakeDirection.RIGHT:
		direction = Vector2.RIGHT
	for i in range(init_length):
		spawn_body(init_position - (i+1) * direction * size)


func stop():
	$Timer.stop()


func start():
	$Timer.start()


func speed_up():
	$Timer.wait_time = 10 / speed


func normal_speed():
	$Timer.wait_time = 50 / speed


func get_length():
	return len(nodes)


func grow_up(value: int):
	for i in range(value):
		spawn_body(positions[-1])


func _on_timer_timeout() -> void:
	if direction.x == 0 && next_direction.x != 0:
		direction = Vector2(next_direction.x / abs(next_direction.x), 0)
	elif direction.y == 0 && next_direction.y != 0:
		direction = Vector2(0, next_direction.y / abs(next_direction.y))
	var new_position = positions[0] + direction * size
	positions.insert(0, new_position)
	positions.remove_at(len(positions) - 1)
	for i in range(len(nodes)):
		nodes[i].position = positions[i]
	move_done.emit(new_position)
	var bodies = positions.slice(1)
	if self_collision:
		for i in bodies:
			if is_equal_approx(i.x, new_position.x) && is_equal_approx(i.y, new_position.y):
				collision.emit()


func _on_main_game_over() -> void:
	stop()


func _on_hud_start_game() -> void:
	start()


func _on_main_game_win() -> void:
	stop()
