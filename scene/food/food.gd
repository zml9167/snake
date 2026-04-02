extends MeshInstance2D

@export var color := Color()
@export var size := 20

func _ready() -> void:
	modulate = color
	mesh.size = Vector2(20, 20)
