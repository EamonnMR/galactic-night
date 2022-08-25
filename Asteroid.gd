extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Asteroid_body_entered(body):
	if body.has_method("hit_by_asteroid"):
		body.hit_by_asteroid()
		break_up()
	
func hit_by_projectile():
	break_up()

func break_up():
	# TODO: Spawn small asteroids
	queue_free()
