extends Crafting

func _blueprints():
	return Data.ships
	
func _get_icon_texture(blueprint):
	return blueprint.icon

func _get_product_description(blueprint):
	return blueprint.desc

func _get_product_name(blueprint):
	return blueprint.type_name

func _do_craft():
	var new_ship = current_blueprint.scene.instantiate()
	new_ship.type = current_blueprint.id
	Client.replace_player_ship(new_ship)
