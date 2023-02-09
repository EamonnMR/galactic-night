extends NinePatchRect

var initial_position

func _ready():
	set_radius(100)

var mods = {
	Util.DISPOSITION.FRIENDLY: Color(0,1,0),
	Util.DISPOSITION.HOSTILE: Color(1,0,0),
	Util.DISPOSITION.NEUTRAL: Color(1,1,0),
	Util.DISPOSITION.ABANDONED: Color(0.5,0.5,0.5)
}

func set_disposition(new_disposition: Util.DISPOSITION):
	#texture = textures[new_disposition]
	modulate = mods[new_disposition]

func set_radius(size: int):
	custom_minimum_size.x = size
	custom_minimum_size.y = size
	position = -1 * custom_minimum_size / 2
