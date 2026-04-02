extends MeshInstance2D

@export var color: Color
@export var size: int


func _ready() -> void:
	modulate = color
	mesh.size.x = size
	mesh.size.y = size
