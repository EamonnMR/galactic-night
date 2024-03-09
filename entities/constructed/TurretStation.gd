extends StaticBody3D

var is_planet = false
var is_populated = true
var spob_name = display_name()
var engagement_range = 10
var faction

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

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path",
		"spob_name"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)

func spob_interact():
	# TODO: arming menu
	pass

func add_weapon(_ignore):
	pass

func remove_weapon(_ignore):
	pass
