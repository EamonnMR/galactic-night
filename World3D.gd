extends Node

var asteroid_count = 4

func _ready():
	var badguy = preload("res://Adversary.tscn").instantiate()
	badguy.global_position = Util.raise_25d(Vector2(5,5))
	add_child(badguy)
	
	for i in range(asteroid_count):
		var asteroid = preload("res://AsteroidLarge.tscn").instantiate()
		asteroid.global_position = Util.raise_25d(Vector2(
			randf_range(0, 40),
			randf_range(0, 40)
		))
		add_child(asteroid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
