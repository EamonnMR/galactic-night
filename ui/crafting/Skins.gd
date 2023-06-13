extends Crafting

func _blueprints():
	return Data.skins
	
func _get_icon_texture(blueprint):
	return blueprint.icon

func _get_product_description(blueprint):
	return blueprint.desc

func _get_product_name(blueprint):
	return blueprint.name

func _do_craft():
	Client.switch_skin(current_blueprint.id)
