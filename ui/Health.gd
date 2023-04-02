extends VBoxContainer

func _process(delta):
	if is_instance_valid(Client.player):
		var health: Health = Client.player.get_node("Health")
		%Armor.value = (float(health.health) / float(health.max_health)) * %Armor.max_value
		%Shields.value = (float(health.shields) / float(health.max_shields)) * %Shields.max_value

	else:
		%Armor.value = 0
		%Shields.value = 0
