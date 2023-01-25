extends Sprite2D

@export var parent: Node3D

func _ready():
	
	parent = get_parent()
	parent.remove_child(self)
	get_tree().get_root().get_node("Main").add_spob_sprite(self)
	
	if parent.type != null and parent.type != "":
		var type_str = get_parent().type
		var type: SpobData = Data.spob_types[type_str]
		texture = type.texture
		material = material.duplicate(true)
		material.set_shader_parameter("radius", type.radius)
		material.set_shader_parameter("offset", type.offset)

func _process(delta):
	position = Client.camera.unproject_position(parent.global_position)
