extends Sprite2D

@export var parent: Node3D

func _ready():
	parent = get_parent()
	self._deferred_ready.call_deferred()

func _deferred_ready():
	var main = get_tree().get_root().get_node("Main")
	parent.remove_child(self)
	main.add_spob_sprite(self)
	
	if parent.type != null and parent.type != "":
		var type_str = parent.type
		var type: SpobData = Data.spob_types[type_str]
		texture = type.texture
		material = material.duplicate(true)
		material.set_shader_parameter("radius", type.radius)
		material.set_shader_parameter("offset", type.offset)

func _process(_delta):
	if parent:
		position = Client.camera.unproject_position(parent.global_position)
