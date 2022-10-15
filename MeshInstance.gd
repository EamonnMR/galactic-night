@tool
extends MeshInstance3D

# BIG TODO: FIX SHADER!!!

@export var offset = PI/4
@export var ortho_cam_angle = PI/4

var thrusting: bool = false
var weapons_glow: bool = false
var base_glow: bool = true

var weapon_glow_floating: float = 0
var engine_glow_floating: float = 0

var default_hue = Color(1,0,0).h

var material: Material

func _ready():
	material = mesh.surface_get_material(0).duplicate(true)
	set_surface_override_material(0, material)
	
func _process(delta):
	var small_delta = delta
	var xform = \
		Transform3D(global_transform.basis)\
		.rotated(Vector3(0,1,0), offset)\
		.rotated(Vector3(1,0,0), ortho_cam_angle)
	if material != null and material.has_method("set_shader_parameter"):
		material.set_shader_parameter("xform", xform)
		material.set_shader_parameter("inv_xform", xform.inverse())
	if thrusting:
		engine_glow_floating += small_delta
		if engine_glow_floating >= 1:
			engine_glow_floating = 1
	else:
		engine_glow_floating -= small_delta
		if engine_glow_floating <= 0:
			engine_glow_floating = 0
	if material != null and material.has_method("set_shader_parameter"):
		material.set_shader_parameter("engine_emission_factor", engine_glow_floating)
		material.set_shader_parameter("weapon_emission_factor", weapon_glow_floating)
	weapon_glow_floating -= small_delta
	if weapon_glow_floating < 0:
		weapon_glow_floating = 0

func flash_weapon():
	weapon_glow_floating = 1

func set_skin_data(skin: SkinData):
	skin.apply_to_shader(material)
