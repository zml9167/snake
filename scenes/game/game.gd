extends Node2D

@export var self_collision: bool = true

const BASE_INTERVAL := 0.5      # 初始每步耗时（秒）
const MIN_INTERVAL := 0.1       # 速度上限（Timer 单帧最多触发一次，别低于 ~0.05）
const STEP_PER_FOOD := 0.01     # 每吃一个食物缩短的秒数
const BOOST_SCALE := 0.5        # 按住加速键时的间隔倍率
const START_LENGTH := 2         # 初始蛇长
const MAX_QUEUED_DIRECTIONS := 2 # 最多缓存两次转向，避免快速二连转向丢失
const MOVE_THRESHOLD := 0.65

var _snake_nodes: Array[Block]
var _head_index: int
var _snake_length: int
var _direction := Vector2.RIGHT
var _direction_queue: Array[Vector2]
var _dir_write_index: int
var _dir_read_index: int
var _grid: GameGrid
var _is_game_over: bool = false
var _start_index: int
var _last_tail_position: Vector2


func _init() -> void:
	_direction_queue.resize(MAX_QUEUED_DIRECTIONS)
	_direction_queue.fill(Vector2.ZERO)


@export var food_color: Color = Color(randf(), randf(), randf(), 1.0)
@export var snake_head_color = Color.BLACK
@export var snake_body_color = Color.WHITE

@onready var viewport_size = get_viewport().get_visible_rect().size
@onready var timer: Timer = $Timer
@onready var snake: Node2D = $Snake
@onready var food: Block = $Food
@onready var line_2d: Line2D = $Line2D


func _ready() -> void:
	_init_grid()
	_draw_boundary()
	_init_snake()
	_init_food()
	_spawn_food()
	timer.wait_time = _tick_interval()
	timer.start()


func _init_grid() -> void:
	_grid = GameGrid.new()
	_grid.shape.x = Global.config.grid_columns
	_grid.shape.y = Global.config.grid_rows
	_grid.cell_count = _grid.shape.x * _grid.shape.y
	var cell_width = viewport_size.x / Global.config.grid_columns
	var cell_height = viewport_size.y / Global.config.grid_rows
	if cell_width == cell_height:
		_grid.cell_size = cell_width
		_grid.offset.x = 0
		_grid.offset.y = 0
	elif cell_width < cell_height:
		_grid.cell_size = cell_width
		_grid.offset.x = 0
		_grid.offset.y = (viewport_size.y - _grid.cell_size * Global.config.grid_rows) / 2
	else:
		_grid.cell_size = cell_height
		_grid.offset.x = (viewport_size.x - _grid.cell_size * Global.config.grid_columns) / 2
		_grid.offset.y = 0
	_grid.size.x = _grid.cell_size * Global.config.grid_columns
	_grid.size.y = _grid.cell_size * Global.config.grid_rows


func _process(_delta: float) -> void:
	if _is_game_over:
		return

	var interval := _tick_interval()
	if not is_equal_approx(timer.wait_time, interval):
		timer.wait_time = interval

	var requested: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if requested.is_zero_approx():
		return
	if abs(requested.x) > MOVE_THRESHOLD: requested.x = roundf(requested.x)
	else: requested.x = 0.0
	if abs(requested.y) > MOVE_THRESHOLD: requested.y = roundf(requested.y)
	else: requested.y = 0.0
	var last_direction := _direction
	var last_write_index = _dir_write_index - 1
	if last_write_index < 0:
		last_write_index += _direction_queue.size()
	last_write_index  = last_write_index % _direction_queue.size()
	if not _direction_queue[last_write_index].is_zero_approx():
		last_direction = _direction_queue[last_write_index]
	if requested.is_equal_approx(last_direction) or (requested + last_direction).is_zero_approx():
		return
	if _direction_queue[_dir_write_index].is_zero_approx():
		_direction_queue[_dir_write_index] = requested
		_dir_write_index = (_dir_write_index + 1) % _direction_queue.size()


# 当前每步耗时：基础值随蛇长递减，按住加速键再乘倍率，最后夹到下限
func _tick_interval() -> float:
	var grown := maxi(_snake_length - START_LENGTH, 0)
	var interval := BASE_INTERVAL - grown * STEP_PER_FOOD
	if Input.is_action_pressed("speed_up"):
		interval *= BOOST_SCALE
	return maxf(interval, MIN_INTERVAL)


func _draw_boundary():
	line_2d.add_point(_grid.offset)
	line_2d.add_point(_grid.offset + Vector2(_grid.size.x, 0))
	line_2d.add_point(_grid.offset + Vector2(_grid.size.x, 0) + Vector2(0, _grid.size.y))
	line_2d.add_point(_grid.offset + Vector2(0, _grid.size.y))
	line_2d.closed = true


func _get_snake_head() -> Block:
	return _snake_nodes[_head_index]


func _get_snake_tail() -> Block:
	var tail_index = (_head_index + _snake_length - 1) % _snake_nodes.size()
	return _snake_nodes[tail_index]


func _get_snake(i: int) -> Block:
	var index = (_head_index + i) % _snake_nodes.size()
	return _snake_nodes[index]


func _init_snake():
	_start_index = _grid.position2index(_grid.offset + _grid.size / 2)
	_snake_nodes.resize(_grid.cell_count)
	_snake_nodes[0] = snake.get_child(0)
	_snake_length = 1
	var head = _get_snake_head()
	head.initialize(Vector2(_grid.cell_size, _grid.cell_size))
	head.position = _grid.index2position(_start_index)
	head.modulate = snake_head_color
	snake.show()
	for i in range(START_LENGTH - 1):
		_spawn_snake_block(_grid.index2position(_start_index - 1 - i))


func _spawn_snake_block(pos: Vector2) -> void:
	var block = _get_snake_head().duplicate()
	block.position = pos
	block.modulate = snake_body_color
	snake.add_child(block)
	_snake_nodes[(_head_index + _snake_length) % _snake_nodes.size()] = block
	_snake_length += 1


func _snake_grow_up(length: int) -> void:
	if length <= 0:
		return
	for i in length:
		_spawn_snake_block(_last_tail_position)


func _update_snake_head() -> Block:
	var head = _get_snake_head()
	head.modulate = snake_body_color
	var tail_index = (_head_index + _snake_length - 1) % _snake_nodes.size()
	_last_tail_position = _snake_nodes[tail_index].position
	_snake_nodes[tail_index].position = head.position + _direction * _grid.cell_size
	_head_index -= 1
	if _head_index < 0:
		_head_index += _snake_nodes.size()
	_head_index = _head_index % _snake_nodes.size()
	_snake_nodes[_head_index] = _snake_nodes[tail_index]
	_snake_nodes[tail_index] = null
	head = _get_snake_head()
	head.modulate = snake_head_color
	return head


func _init_food():
	food.initialize(Vector2(_grid.cell_size, _grid.cell_size)) 
	food.modulate = food_color


func _spawn_food() -> bool:
	var excluded = []
	for i in _snake_length:
		excluded.append(_grid.position2index(_get_snake(i).position))
	var candidates = []
	for i in range(_grid.cell_count):
		if i not in excluded:
			candidates.append(i)
	if candidates.is_empty():
		_end_game("finish")
		return false

	var random = candidates.pick_random()
	food.position = _grid.index2position(random)

	return true


func _on_timer_timeout() -> void:
	if _is_game_over:
		return

	while not _direction_queue[_dir_read_index].is_zero_approx():
		var next: Vector2 = _direction_queue[_dir_read_index]
		_direction_queue[_dir_read_index] = Vector2.ZERO
		_dir_read_index = (_dir_read_index + 1) % _direction_queue.size()
		if is_zero_approx(_direction.x) and not is_zero_approx(next.x):
			_direction = Vector2(next.x, 0)
			break
		if is_zero_approx(_direction.y) and not is_zero_approx(next.y):
			_direction = Vector2(0, next.y)
			break
	var head = _update_snake_head()
	if food.position.is_equal_approx(head.position):
		_snake_grow_up(1)
		if not _spawn_food():
			return

	if (
		head.position.x < _grid.offset.x
		or head.position.x > _grid.offset.x + _grid.size.x
		or head.position.y < _grid.offset.y
		or head.position.y > _grid.offset.y + _grid.size.y
	):
		_end_game("end")
		return

	if self_collision and _is_head_on_body():
		_end_game("self collision")
		return


func _is_head_on_body() -> bool:
	var head_index = _grid.position2index(_get_snake_head().position)
	for i in range(1, _snake_length):
		if _grid.position2index(_get_snake(i).position) == head_index:
			return true
	return false


func _end_game(reason: String) -> void:
	if _is_game_over:
		return
	print(reason)
	_is_game_over = true
	timer.stop()
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
