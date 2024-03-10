extends StaticBody3D

var is_planet = false
var is_populated = true
var spob_name = display_name()
var engagement_range = 10
var faction = "player_owned"
var linear_velocity = Vector2(0,0)
var weapons = []

func display_name():
	return "Turret"
	
func display_type():
	return "Station"

func _ready():
	add_to_group("radar-spobs")
	add_to_group("player-assets")
	Util.clickable_spob(self)
	# TODO: Set up way to replace weapons
	$WeaponSlot.add_weapon(WeaponData.instantiate("plasma"))
	
func _physics_process(delta):
	_handle_shooting()

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path",
		"spob_name"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)

func flash_weapon():
	pass

func spob_interact():
	# TODO: arming menu
	pass

func add_weapon(weapon):
	weapons.append(weapon)

func remove_weapon(weapon):
	weapons.erase(weapon)

func _handle_shooting():
	if $Controller.shooting:
		for weapon in weapons:
			weapon.try_shoot()
