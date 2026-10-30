extends Node2D

class_name Block

@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@onready var line_2d: Line2D = $Line2D


func initialize(size: Vector2) -> void:
	mesh_instance_2d.mesh.size = size
	var x = size.x / 2.0
	var y = size.y / 2.0
	line_2d.add_point(Vector2(-x, -y))
	line_2d.add_point(Vector2(x, -y))
	line_2d.add_point(Vector2(x, y))
	line_2d.add_point(Vector2(-x, y))
	line_2d.closed = true
