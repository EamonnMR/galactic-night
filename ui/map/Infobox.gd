extends NinePatchRect

@onready var name_textbox = get_node("MarginContainer/VBoxContainer/Name")
@onready var biome = get_node("MarginContainer/VBoxContainer/Biome")
@onready var spobs = get_node("MarginContainer/VBoxContainer/Spobs")
@onready var faction = get_node("MarginContainer/VBoxContainer/Faction")

func _ready():
	Client.connect("system_selection_updated",Callable(self,"_update"))

func _update():
	var sysdat: SystemData = Procgen.systems[Client.selected_system]
	print("Updated; system explored: ", sysdat.explored)
	if sysdat.explored or Cheats.explore_all:
		name_textbox.text = "Name: "+ sysdat.name
		biome.text = "Biome: " + Data.biomes[sysdat.biome].name
		if sysdat.faction != "":
			faction.text = "Faction: " + Data.factions[sysdat.faction].name + " (" + sysdat.faction + ")"
		else:
			faction.text = "Faction: None"
		if "spobs" in sysdat.entities:
			var spob_names: PackedStringArray = []
			for spob in sysdat.entities.spobs:
				spob_names.push_back(spob.spob_name)
			spobs.text = "Spobs: " + ("\n".join(spob_names))
		else:
			spobs.text = ""
	else:
		name_textbox.text = "Unexplored System"
		biome.text = "Unknown"
