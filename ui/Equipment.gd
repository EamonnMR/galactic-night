extends Control

var equip_box = preload("res://ui/EquipBox.tscn")

func _ready():
	Client.player_ship_updated.connect(rebuild)

func clear():
	for i in [%LeftEquip, %MiddleEquip, %RightEquip]:
		for child in i.get_children():
			if not ((child is MarginContainer) or (child is TextureRect) or (child is RichTextLabel)):
				i.remove_child(child)
				child.queue_free()

func rebuild():
	clear()
	
	var player = Client.player
	var equipment = Client.player.get_node("Equipment")
	# TODO: 
	var ship_type = Data.ships[Client.player.type]
	# preview.texture = player.get_node("Sprite").texture
	%Type.text = ship_type.name
	# Populate panels with slots for the ship
	for i in [
		[Equipment.CATEGORY.CONSUMABLE, %MiddleEquip],
		[Equipment.CATEGORY.SHIELD, %LeftEquip],
		[Equipment.CATEGORY.HYPERDRIVE, %LeftEquip],
		[Equipment.CATEGORY.REACTOR, %LeftEquip],
		[Equipment.CATEGORY.ARMOR, %LeftEquip],
		[Equipment.CATEGORY.WEAPON, %RightEquip]
	]:
		# I yearn for Tuples
		var category = i[0]
		var destination = i[1]
		var equipment_slots = equipment.slot_keys[category]
		for slot in equipment_slots:
			var box = equip_box.instantiate()
			box.category = category
			
			if equipment_slots[slot]:
				var item = equipment_slots[slot]
				var icon: ItemIcon = ItemIcon.instantiate()
				icon.init(item)
				box.attach_item_icon(icon)
			destination.add_child(box)

			box.item_removed.connect(equipment.remove_item.bind(slot, category))
			box.item_added.connect(equipment.equip_item.bind(slot, category))
