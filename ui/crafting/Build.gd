extends Crafting

func _blueprints():
	return Data.builds
	
func _get_icon_texture(blueprint):
	return blueprint.icon

func _get_product_description(blueprint):
	return blueprint.text

func _get_product_name(blueprint):
	return blueprint.name

func _do_craft():
	var constructed = current_blueprint.scene.instantiate()
	Client.player.get_node("Inventory").deduct_ingredients(current_blueprint.ingredients)
	constructed.position = Client.player.position
	get_tree().get_root().get_node("Game/Gameplay/" + current_blueprint.destination).add_child(
		constructed
	)
