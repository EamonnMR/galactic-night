extends HBoxContainer

func assign(ingredients: Dictionary):
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for ingredient_type in ingredients:
		var item_data = Data.items[ingredient_type]
		var ingredient_quantity = ingredients[ingredient_type]
		var eqb = EquipBox
		var ingredient_icon_box = preload("res://ui/EquipBox.tscn").instantiate()
		var ingredient_icon = preload("res://ui/ItemIcon.tscn").instantiate()
		
		ingredient_icon.init_fake(ingredient_type, ingredient_quantity)
		
		ingredient_icon_box.add_child(ingredient_icon)
		add_child(ingredient_icon_box)
	
	# get_node("CraftButton").disabled = true
