extends Node3D

@export var drop_chance: float
# @export var drop_inventory: float
@export var loot_items: Dictionary

var initial_vel: float = 1.5

func _ready():
	get_node("../").connect("destroyed", self.drop)

func _physics_process(_delta):
	Util.wrap_to_play_radius(self)

func drop():
	# TODO: make drop inventory work
	for item_type in loot_items:
		for i in range(loot_items[item_type]):
			# TODO: We need a fixed RNG, right?
			if randf() <= drop_chance:
				var pickup = preload("res://entities/pickup.tscn").instantiate()
				pickup.type = item_type
				Client.get_world().get_node("pickups").add_child(pickup)
				pickup.transform.origin = global_transform.origin
