extends Node2D

export var start: String = ""
export var end: String = ""

var data: HyperlaneData

func _draw():
	draw_line(
		Procgen.systems[data.lsys].position,
		Procgen.systems[data.rsys].position,
		Color(.7,.7,.7)
	)
