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
	Client.get_world().get_node(
		current_blueprint.destination
	).add_child(
		constructed
	)

func _get_codex_path(current_blueprint):
	return current_blueprint.derive_codex_path()
	
func _has_codex_path(current_blueprint):
	var path = _get_codex_path(current_blueprint)
	var has_entry = Data.has_codex_entry(_get_codex_path(current_blueprint))
	return has_entry
