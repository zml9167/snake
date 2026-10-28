extends Node2D

@export var self_collision: bool = true

const BASE_INTERVAL := 0.5      # 初始每步耗时（秒）
const MIN_INTERVAL := 0.1       # 速度上限（Timer 单帧最多触发一次，别低于 ~0.05）
const STEP_PER_FOOD := 0.01     # 每吃一个食物缩短的秒数
const BOOST_SCALE := 0.5        # 按住加速键时的间隔倍率
const START_LENGTH := 2         # 初始蛇长
const MAX_QUEUED_DIRECTIONS := 2 # 最多缓存两次转向，避免快速二连转向丢失

@onready var viewport_size = get_viewport().get_visible_rect().size
@onready var timer: Timer = $Timer
@onready var snake: Node2D = $Snake
@onready var food: Node2D = $Food
@onready var line_2d: Line2D = $Line2D

var snake_nodes: Array[MeshInstance2D] = []
var direction: Vector2 = Vector2.RIGHT
var direction_queue: Array[Vector2] = []
var food_node: MeshInstance2D
var grid: GameGrid
var is_game_over: bool = false
var boost: bool = false

var start_index: int
var mesh: Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = GameGrid.new()
	grid.shape.x = Global.config.grid_columns
	grid.shape.y = Global.config.grid_rows
	var cell_width = viewport_size.x / Global.config.grid_columns
	var cell_height = viewport_size.y / Global.config.grid_rows
	if cell_width == cell_height:
		grid.cell_size = cell_width
		grid.offset.x = 0
		grid.offset.y = 0
	elif cell_width < cell_height:
		grid.cell_size = cell_width
		grid.offset.x = 0
		grid.offset.y = (viewport_size.y - grid.cell_size * Global.config.grid_rows) / 2
	else:
		grid.cell_size = cell_height
		grid.offset.x = (viewport_size.x - grid.cell_size * Global.config.grid_columns) / 2
		grid.offset.y = 0
	grid.size.x = grid.cell_size * Global.config.grid_columns
	grid.size.y = grid.cell_size * Global.config.grid_rows
	_draw_boundary()
	grid.cell_count = Global.config.grid_columns * Global.config.grid_rows
	start_index = grid.position2index(viewport_size / 2)
	mesh = QuadMesh.new()
	mesh.size.x = grid.cell_size
	mesh.size.y = grid.cell_size
	_spawn_snake()
	snake_nodes[0].modulate = Color()
	_init_food()
	_spawn_food()
	timer.wait_time = _tick_interval()
	timer.start()


func _physics_process(_delta: float) -> void:
	if is_game_over:
		return

	var pressed := Input.is_action_pressed("speed_up")
	if pressed != boost:
		boost = pressed

	var interval := _tick_interval()
	if not is_equal_approx(timer.wait_time, interval):
		timer.wait_time = interval


# 当前每步耗时：基础值随蛇长递减，按住加速键再乘倍率，最后夹到下限
func _tick_interval() -> float:
	var grown := maxi(snake_nodes.size() - START_LENGTH, 0)
	var interval := BASE_INTERVAL - grown * STEP_PER_FOOD
	if boost:
		interval *= BOOST_SCALE
	return maxf(interval, MIN_INTERVAL)


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over:
		return

	var requested := Vector2.ZERO
	if event.is_action_pressed("move_left"):
		requested = Vector2.LEFT
	elif event.is_action_pressed("move_right"):
		requested = Vector2.RIGHT
	elif event.is_action_pressed("move_up"):
		requested = Vector2.UP
	elif event.is_action_pressed("move_down"):
		requested = Vector2.DOWN

	if requested == Vector2.ZERO:
		return

	var last_direction := direction
	if not direction_queue.is_empty():
		last_direction = direction_queue[-1]
	if requested == last_direction or (requested + last_direction).is_zero_approx():
		return
	if direction_queue.size() < MAX_QUEUED_DIRECTIONS:
		direction_queue.push_back(requested)


func _draw_boundary():
	line_2d.points = PackedVector2Array([
		grid.offset, grid.offset + Vector2(grid.size.x, 0),
		grid.offset + Vector2(grid.size.x, 0) + Vector2(0, grid.size.y),
		grid.offset + Vector2(0, grid.size.y)
	])


func _spawn_snake():
	for i in range(START_LENGTH):
		_spawn_snake_node(start_index - i)


func _snake_add_node(instance: MeshInstance2D):
	snake.add_child(instance)
	snake_nodes.append(instance)


func _spawn_snake_node(index: int):
	var instance = MeshInstance2D.new()
	instance.position = grid.index2position(index)
	instance.mesh = mesh
	_snake_add_node(instance)


func _snake_grow_up(value: int):
	for i in range(value):
		var instance = snake_nodes[-1].duplicate()
		_snake_add_node(instance)


func _init_food():
	food_node = MeshInstance2D.new()
	food_node.mesh = mesh
	food.add_child(food_node)
	food.modulate = Color(randf(), randf(), randf())


func _spawn_food() -> bool:
	var excluded = []
	for node in snake_nodes:
		excluded.append(grid.position2index(node.position))
	var candidates = []
	for i in range(grid.cell_count):
		if i not in excluded:
			candidates.append(i)
	if candidates.is_empty():
		_end_game("finish")
		return false

	var random = candidates.pick_random()
	food_node.position = grid.index2position(random)

	return true


func _on_timer_timeout() -> void:
	if is_game_over:
		return

	snake_nodes[0].modulate = Color(1,1,1)

	while not direction_queue.is_empty():
		var next: Vector2 = direction_queue.pop_front()
		if not (next + direction).is_zero_approx():
			direction = next
			break

	var node = snake_nodes.pop_back()
	node.position = snake_nodes[0].position + direction * grid.cell_size
	node.modulate = Color()
	snake_nodes.push_front(node)

	if food_node.position.is_equal_approx(snake_nodes[0].position):
		if not _spawn_food():
			return
		_snake_grow_up(1)

	if (
		node.position.x < grid.offset.x
		or node.position.x > grid.offset.x + grid.size.x
		or node.position.y < grid.offset.y
		or node.position.y > grid.offset.y + grid.size.y
	):
		_end_game("end")
	elif self_collision and _is_head_on_body():
		_end_game("self collision")


func _is_head_on_body() -> bool:
	var head_index = grid.position2index(snake_nodes[0].position)
	for i in range(1, snake_nodes.size()):
		if grid.position2index(snake_nodes[i].position) == head_index:
			return true
	return false


func _end_game(reason: String) -> void:
	if is_game_over:
		return
	is_game_over = true
	timer.stop()
	print(reason)
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
