extends CanvasLayer

var inventory_open = false

func new_map():
	var map = preload("res://ui/map/Map.tscn").instantiate()
	map.hide()
	add_child(map)

func get_default_children():
	return [
		$Equipment,
		$Crafting,
		$Inventory,
		$Money
	]

func get_all_inventory_children():
	return get_default_children() + [
		$InhabitedSpob
	]

func toggle_map():
	if not toggle_modal($Map):
		$Map.unassign()

func toggle_codex(entry=null):
	if entry != null:
		$Codex.select_entry_by_path(entry)
	toggle_modal($Codex)

func toggle_modal(modal):
	if modal.visible:
		modal.visible = false
		if not inventory_open:	
			get_tree().paused = false
		return false
	else:
		modal.visible = true
		get_tree().paused = true
		return true

func toggle_inventory(elements: Array = []):
	if inventory_open:
		for i in get_all_inventory_children():
			i.hide()
			if i.has_method("unassign"):
				i.unassign()
		get_tree().paused = false
		inventory_open = false
	else:
		var children = []
		if elements.size() == 0:
			children = get_default_children()
		else:
			for i in elements:
				children.push_back(get_node(i))
		
		for i in children:
			i.rebuild()
			i.show()
		get_tree().paused = true
		inventory_open = true

