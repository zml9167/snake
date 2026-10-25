class_name GameGrid

var colums: int
var rows: int
var cell_size: float
var offset: Vector2
var total: int
var size: Vector2

func index2position(index: int):
	var row = int(index / colums)
	var col = index % colums
	var pos = Vector2(col+0.5, row+0.5) * cell_size
	return pos + offset

func position2index(pos: Vector2) -> int:
	var res = Vector2i((pos - offset) / cell_size)
	var index = res.y * colums + res.x
	return index
