extends CharacterBody3D

var iff: IffProfile
var damage: int
var linear_velocity = Vector2()
var initial_velocity = 10

func _ready():
	linear_velocity += Vector2(initial_velocity, 0).rotated(-rotation.y)

func _physics_process(_delta):
	set_velocity(Util.raise_25d(linear_velocity))
	move_and_slide()
	Util.wrap_to_play_radius(self)


func _on_Projectile_body_entered(body):
	if not iff.should_exclude(body):
		queue_free()
		Health.do_damage(body, damage, iff.owner)


func _on_Timer_timeout():
	queue_free()
