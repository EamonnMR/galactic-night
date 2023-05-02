extends Crafting

func _blueprints():
	return Data.ships
	
func _get_icon_texture(blueprint):
	return blueprint.icon

func _get_product_description(blueprint):
	return blueprint.desc

func _get_product_name(blueprint):
	return blueprint.name

func _do_craft():
	Client.switch_ship(current_blueprint.id)
