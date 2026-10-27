class_name GameGrid

var shape: Vector2i
var cell_size: float
var offset: Vector2
var total: int
var size: Vector2

func index2position(index: int):
	@warning_ignore("integer_division")
	var row = int(index / shape.x)
	var col = index % shape.x
	var pos = Vector2(col+0.5, row+0.5) * cell_size
	return pos + offset

func position2index(pos: Vector2) -> int:
	var res = Vector2i((pos - offset) / cell_size)
	var index = res.y * shape.x + res.x
	return index
