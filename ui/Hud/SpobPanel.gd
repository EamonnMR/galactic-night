extends NinePatchRect

var spob

func _ready():
	hide()
	Client.spob_target_updated.connect(
		func _on_target_changed():
			spob = Client.target_spob
			if spob.has_method("display_name"):
				%Name.text = spob.display_name()
			else:
				%Name.text = "Unnamed"
			
			if spob.has_method("display_type"):
				%Type.text = spob.display_type()
			else:
				%Type.text = "Unknown Type"
			
			%Faction.text = _get_spob_faction_text()

			show()
			# TODO: Resize to target size
			if spob.has_signal("destroyed"):
				spob.destroyed.connect(_on_target_exited)
			Client.exited_system.connect(_on_target_exited)
	)

func _get_spob_faction_text():
	if spob.is_in_group("player-assets"):
		return "Player" # TODO: Player faction name?
	elif "faction" in spob and spob.faction != "":
		return Data.factions[spob.faction].name
	else:
		return "uninhabited"

func _on_target_exited():
	hide()
	spob = null
