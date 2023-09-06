extends NinePatchRect

func _ready():
	Client.system_selection_updated.connect(_update)

func _update():
	var sysdat: SystemData = Procgen.systems[Client.selected_system]
	print("Updated; system explored: ", sysdat.explored)
	if sysdat.explored or Cheats.explore_all:
		%Name.text = "Name: "+ sysdat.name
		%Biome.text = "Biome: " + Data.biomes[sysdat.biome].name
		if sysdat.faction != "":
			%Faction.text = "Faction: " + Data.factions[sysdat.faction].name
		else:
			%Faction.text = "Faction: None"
		if "spobs" in sysdat.entities:
			var spob_names: PackedStringArray = []
			for spob in sysdat.entities.spobs:
				if "spob_name" in spob:
					spob_names.push_back(spob.spob_name)
			%Spobs.text = "Spobs: " + ("\n".join(spob_names))
		else:
			%Spobs.text = ""
	else:
		%Name.text = "Unexplored System"
		%Biome.text = "Unknown"
		%Faction.text = ""
		%Spobs.text = ""
