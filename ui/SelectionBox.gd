extends NinePatchRect

var initial_position

func _ready():
	set_radius(100)

var textures = {
	Util.DISPOSITION.FRIENDLY: preload("res://assets/danc_cc_by/selection_friendly.png"),
	Util.DISPOSITION.HOSTILE: preload("res://assets/danc_cc_by/selection_hostile.png"),
	Util.DISPOSITION.NEUTRAL: preload("res://assets/danc_cc_by/selection_friendly.png"),
	Util.DISPOSITION.ABANDONED: preload("res://assets/danc_cc_by/selection_abandoned.png"),
}

func set_disposition(new_disposition: Util.DISPOSITION):
	texture = textures[new_disposition]

func set_radius(size: int):
	custom_minimum_size.x = size
	custom_minimum_size.y = size
	position = -1 * custom_minimum_size / 2
