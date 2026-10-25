extends Node2D

@export var self_collision: bool = true

@onready var viewport_size = get_viewport().get_visible_rect().size
@onready var timer: Timer = $Timer
@onready var snake: Node2D = $Snake
@onready var food: Node2D = $Food
@onready var line_2d: Line2D = $Line2D

var snake_nodes: Array[MeshInstance2D] = []
var direction = Vector2.RIGHT
var next_direction = Vector2.ZERO
var food_node: MeshInstance2D
var grid: GameGrid

var start_index: int
var mesh: Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = GameGrid.new()
	grid.colums = Global.config.grid_colums
	grid.rows = Global.config.grid_rows
	var cell_width = viewport_size.x / Global.config.grid_colums
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
		grid.offset.x = (viewport_size.x - grid.cell_size * Global.config.grid_colums) / 2
		grid.offset.y = 0
	grid.size.x = grid.cell_size * Global.config.grid_colums
	grid.size.y = grid.cell_size * Global.config.grid_rows
	draw_boundary()
	grid.total = Global.config.grid_colums * Global.config.grid_rows
	start_index = grid.position2index(viewport_size / 2)
	mesh = QuadMesh.new()
	mesh.size.x = grid.cell_size
	mesh.size.y = grid.cell_size
	spawn_snake_node(start_index)
	spawn_snake_node(start_index - 1)
	snake_nodes[0].modulate = Color()
	init_food()
	spawn_food()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("speed_up"):
		timer.wait_time = 0.5
	else:
		timer.wait_time = 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		next_direction = Vector2.LEFT
	elif event.is_action_pressed("move_right"):
		next_direction = Vector2.RIGHT
	elif event.is_action_pressed("move_up"):
		next_direction = Vector2.UP
	elif event.is_action_pressed("move_down"):
		next_direction = Vector2.DOWN


func draw_boundary():
	line_2d.points = PackedVector2Array([
		grid.offset, grid.offset + Vector2(grid.size.x, 0),
		grid.offset + Vector2(grid.size.x, 0) + Vector2(0, grid.size.y),
		grid.offset + Vector2(0, grid.size.y)
	])

func spawn_snake_node(index: int):
	var instance = MeshInstance2D.new()
	instance.position = grid.index2position(index)
	instance.mesh = mesh
	snake.add_child(instance)
	snake_nodes.append(instance)

func snake_grow_up(value: int):
	for i in range(value):
		var instance = MeshInstance2D.new()
		instance.mesh = mesh
		instance.position = snake_nodes[-1].position
		snake.add_child(instance)
		snake_nodes.append(instance)


func init_food():
	food_node = MeshInstance2D.new()
	food_node.mesh = mesh
	food.add_child(food_node)


func spawn_food():
	var excluded = []
	for node in snake_nodes:
		excluded.append(grid.position2index(node.position))
	var candidates = []
	for i in range(grid.total):
		if i not in excluded:
			candidates.append(i)
	if candidates.is_empty():
		print('finish')
		await get_tree().create_timer(2)
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return

	var random = candidates.pick_random()
	food_node.position = grid.index2position(random)


func _on_timer_timeout() -> void:
	snake_nodes[0].modulate = Color(1,1,1)

	if (
		not next_direction.is_zero_approx()
		and not (next_direction + direction).is_zero_approx()
	):
		direction = next_direction

	var node = snake_nodes.pop_back()
	node.position = snake_nodes[0].position + direction * grid.cell_size
	node.modulate = Color()
	snake_nodes.push_front(node)

	if food_node.position.is_equal_approx(snake_nodes[0].position):
		spawn_food()
		snake_grow_up(1)

	if (
		node.position.x < grid.offset.x
		or node.position.x > grid.offset.x + grid.size.x
		or node.position.y < grid.offset.y
		or node.position.y > grid.offset.y + grid.size.y
	):
		print('end')
		await get_tree().create_timer(2)
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
