extends Crafting

func _blueprints():
	return Data.recipes
	
func _get_icon_texture(blueprint):
	return Data.items[blueprint.prod_item].icon

func _get_product_description(blueprint):
	return Data.items[blueprint.prod_item].tooltip

func _get_product_name(blueprint):
	var item_data = Data.items[blueprint.prod_item]
	var suffix = ""
	if blueprint.prod_count > 1:
		suffix = " x " + str(blueprint.prod_count)
	return item_data.name + suffix

func _do_craft():
	Client.player.get_node("Inventory").add(current_blueprint.prod_item, current_blueprint.prod_count)
