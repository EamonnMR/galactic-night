extends Node3D

var iff: IffProfile
var damage = Health.DamageVal
var ignore_shields: bool = false
var impact: float
var material: StandardMaterial3D
var overpen: bool = false
@export var explosion: PackedScene

@export var max_range = 10
# @export var explosion: PackedScene


func set_lifetime(lifetime: float):
	if lifetime:
		$Timer.wait_time = lifetime

func _process(delta):
	material.albedo_color.a = _fade_factor()
	material.emission_intensity = randf_range(1,2)
		
func _fade_factor():
	return $Timer.time_left / $Timer.wait_time

func _ready():
	$Graphics.mesh = $Graphics.mesh.duplicate(true)
	material = $Graphics.mesh.surface_get_material(0).duplicate(true)
	$Graphics.set_surface_override_material(0, material)
	do_beam.call_deferred(global_transform.origin, [iff.owner])

func init(iff):
	self.iff = iff

func do_beam(origin: Vector3, ignore: Array):
	$Timer.start()
	var length = do_beam_inner(origin, ignore, max_range)
	_update_graphics(length)

func do_beam_inner(origin: Vector3, ignore: Array, remaining_length: float):
	var collision = project_beam(global_transform.origin, ignore, remaining_length)
	if "collider" in collision:
		# TODO: Explosion at collision.position
		var collider = collision.collider
		
		if is_instance_valid(collider) and not iff.should_exclude(collider):
			var owner = null
			if is_instance_valid(iff.owner):
				owner = iff.owner

			Health.do_damage(collider, damage, owner)
			# TODO: Push and pull beams
			#if impact != 0 and body.has_method("receive_impact"):
			#	body.receive_impact(linear_velocity.normalized(), get_falloff_impact(impact))
		var length = (collision.position - global_transform.origin).length()
		if overpen:
			do_beam_inner(collision.position, ignore + [collider], remaining_length - length)
			# Always draw out to max range if it's an overpen beam
			return max_range
		return length
	else:
		return max_range

func _update_graphics(beam_length: float):
	$Graphics.transform.origin.x = beam_length / 2
	$Graphics.mesh.height = beam_length
	
func project_beam(from: Vector3, ignore: Array, distance: float) -> Dictionary:
	var collisionMask = 1
	var to = from + global_transform.basis.x * distance 
	var spaceState: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
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
