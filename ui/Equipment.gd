extends Control

var item_icon = preload("res://ui/ItemIcon.tscn")
var EquipBox = preload("res://ui/EquipBox.tscn")

func _ready():
	Client.connect("player_ship_updated", self.rebuild)

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
	var eq_path = equipment.get_path()
	# TODO: 
	var ship_type = Data.ships[Client.player.type]
	# preview.texture = player.get_node("Sprite").texture
	%Type.text = ship_type.name
	# Populate panels with slots for the ship
	for i in [
		["consumable", %MiddleEquip, preload("res://assets/FontAwesome/32px-charge.png")], # TODO: Better icon
		["shield", %LeftEquip, preload("res://assets/FontAwesome/32px-play.png")],
		["hyperdrive", %LeftEquip, preload("res://assets/FontAwesome/32px-star.png")],
		["reactor", %LeftEquip, preload("res://assets/FontAwesome/32px-charge.png")],
		["armor", %LeftEquip, preload("res://assets/FontAwesome/32px-shield.png")],
		["weapon", %RightEquip, preload("res://assets/FontAwesome/32px-crosshairs.png")]
	]:
		# I yearn for Tuples
		var category = i[0]
		var destination = i[1]
		var background = i[2]
		var equipment_slots = equipment.slot_keys[category]
		for slot in equipment_slots:
			var box = EquipBox.instantiate()
			box.get_node("TextureRect").texture = background
			box.category = category
			
			if equipment_slots[slot]:
				var item = equipment_slots[slot]
				var icon: ItemIcon = item_icon.instantiate()
				icon.init(item)
				box.attach_item_icon(icon)
			destination.add_child(box)

			box.item_removed.connect(equipment.remove_item.bind(slot, category))
			box.item_added.connect(equipment.equip_item.bind(slot, category))
