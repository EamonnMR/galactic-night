extends Node2D

class_name Hyperlane

@export var start: String = ""
@export var end: String = ""


enum TYPE {
	NORMAL,
	LONG,
	WARPGATE
}

@export var type: TYPE = TYPE.NORMAL

var data: HyperlaneData

func color():
	match type:
		TYPE.NORMAL:
			return Color(0.7, 0.7, 0.7)
		TYPE.LONG:
			return Color(0.3, 0.15, 0.15)
		TYPE.WARPGATE:
			return Color(0.7, 0.7, 1.0)

func width():
	if type == TYPE.WARPGATE:
		return 2
	return 1

func _draw():
	draw_line(
		Procgen.systems[data.lsys].position,
		Procgen.systems[data.rsys].position,
		color(),
		width()
	)
