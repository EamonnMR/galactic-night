extends NinePatchRect

onready var name_textbox = get_node("MarginContainer/VBoxContainer/Name")
onready var biome = get_node("MarginContainer/VBoxContainer/Biome")
onready var planets = get_node("MarginContainer/VBoxContainer/Planets")
onready var aliens = get_node("MarginContainer/VBoxContainer/Aliens")
onready var sleepers = get_node("MarginContainer/VBoxContainer/Sleepers")

func _ready():
	Client.connect("system_selection_updated", self, "_update")

func _update():
	var sysdat: SystemData = Procgen.systems[Client.player.get_node("Controller").selected_system]
	print("Updated; system explored: ", sysdat.explored)
	if sysdat.explored:
		name_textbox.text = sysdat.name
		biome.text = Data.biomes[sysdat.biome].name
	else:
		name_textbox.text = "Unexplored System"
		biome.text = "Unknown"
