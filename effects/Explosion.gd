extends Node3D

class_name Explosion

#@export var damage: int = true
#@export var radius: int = true
#@export var friendly_splash: bool = false
# var iff: IffProfile

#func init(damage: int = 0, radius: int = 0, friendly_splash: bool = false, iff: IffProfile = null):
#	self.damage = damage
#	self.radius = radius
#	self.friendly_splash = friendly_splash
#	self.iff = iff

#func immediate_damage():
#	call_deferred("do_damage")

#func do_damage():
#	for body in Util.generic_aoe_query(self, self.global_transform.origin, radius):
#		# if friendly_splash or not iff.should_exclude(body.collider):
#		if not iff or not iff.should_exclude(body.collider):
#			Health.do_damage(body.collider, damage)

func _ready():
	$Particles.emitting = true
	
	set.call_deferred("emitting", true) # To fix explosions staritng at 0,0
	$AudioStreamPlayer3D.play
	$Lifetime.wait_time = $Particles.lifetime * 10
	$Lifetime.start()
#	immediate_damage()
	
func _on_Lifetime_timeout():
	queue_free()

static func make_explo(explo: PackedScene, source: Node3D):
	var explosion = explo.instantiate()
	# TODO
	# explosion.init()
	explosion.global_transform = source.global_transform
	Client.get_world().get_node("explosions").add_child(explosion)
