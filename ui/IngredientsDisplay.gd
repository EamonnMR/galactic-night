extends HBoxContainer

func assign(ingredients: Dictionary):
	var player_inventory: Inventory = Client.player.get_node("Inventory")
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for ingredient_type in ingredients:
		var ingredient_quantity = ingredients[ingredient_type]
		var ingredient_icon_box = preload("res://ui/EquipBox.tscn").instantiate()
		var ingredient_icon = preload("res://ui/ItemIcon.tscn").instantiate()
		
		ingredient_icon.init_fake(ingredient_type, ingredient_quantity)
		
		ingredient_icon_box.add_child(ingredient_icon)

		ingredient_icon_box.mode = \
			EquipBox.FRAME_MODE.SUFFICIENT if \
			player_inventory.has_ingredients({ingredient_type: ingredient_quantity}) else \
			EquipBox.FRAME_MODE.INSUFFICIENT
		
		add_child(ingredient_icon_box)
	
	# get_node("CraftButton").disabled = true
