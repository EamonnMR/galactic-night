extends Node3D

var iff: IffProfile
var mass_damage: int
var energy_damage: int
var ignore_shields: bool = false
#var splash_damage: int
#var splash_radius: int
var linear_velocity = Vector2()
var initial_velocity = 10
var impact: float
var material: StandardMaterial3D# = $MeshInstance3D.surface_get_material(0)
@export var explosion: PackedScene

@export var max_range = 1000
@export var overpen_count = 0
# @export var explosion: PackedScene

func _ready():
	call_deferred("do_beam", global_transform.origin, [iff.owner], 0)

func init(iff):
	self.iff = iff

func do_beam(origin: Vector3, ignore: Array, pen_count):
	var collision = project_beam(global_transform.origin, ignore)
	if "collider" in collision:
		# TODO: Explosion at collision.position
		var collider = collision.collider
		if not iff.should_exclude(collider):
			Health.do_damage(collider, Health.DamageVal.new(
				mass_damage,
				energy_damage,
				ignore_shields
			), iff.owner)
			# TODO: Push and pull beams
			#if impact != 0 and body.has_method("receive_impact"):
			#	body.receive_impact(linear_velocity.normalized(), get_falloff_impact(impact))
		# TODO: Overpen
		#if pen_count < overpen_count or overpen_count < 0: # TODO: Keep track of deducted distance< 0:
			## TODO: Keep track of deducted distance
			#do_beam(collision.position, ignore + [collider], pen_count + 1)
		else:
			_update_graphics((collision.position - global_transform.origin).length())
			# _do_explosion(collision.position)
	else:
		var endpoint = global_transform.origin + global_transform.basis.x * max_range
		_update_graphics(max_range)
		# _do_explosion(endpoint)

func _update_graphics(beam_length: float):
	$Graphics.transform.origin.x += beam_length / 2
	$Graphics.mesh.height = beam_length

func project_beam(from: Vector3, ignore: Array) -> Dictionary:
	var collisionMask = 1
	var to = from + global_transform.basis.x * max_range 
	var spaceState :PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	return spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(
		from, to, collisionMask, ignore
	))
#
#func _do_explosion(location: Vector3):
	#if explosion:
		#var explo = explosion.instantiate()
		#explo.global_transform.origin = location
		#if splash_damage:
			#explo.init(splash_damage, splash_radius, false, iff)
		#get_tree().get_root().add_child(explo)
