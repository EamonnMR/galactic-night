extends NinePatchRect

class_name EquipBox

signal item_removed
signal item_added(item)

@export var disabled: bool = false

@export var category: Equipment.CATEGORY = Equipment.CATEGORY.ANY

enum FRAME_MODE {
	NORMAL,
	SUFFICIENT,
	INSUFFICIENT,
}

@export var mode: FRAME_MODE = FRAME_MODE.NORMAL


const icons = {
	Equipment.CATEGORY.ANY: null,
	Equipment.CATEGORY.CONSUMABLE: preload("res://assets/FontAwesome/32px-charge.png"),
	Equipment.CATEGORY.SHIELD: preload("res://assets/FontAwesome/32px-play.png"),
	Equipment.CATEGORY.HYPERDRIVE: preload("res://assets/FontAwesome/32px-charge.png"),
	Equipment.CATEGORY.REACTOR: preload("res://assets/FontAwesome/32px-charge.png"),
	Equipment.CATEGORY.ARMOR: preload("res://assets/FontAwesome/32px-shield.png"),
	Equipment.CATEGORY.WEAPON: preload("res://assets/FontAwesome/32px-crosshairs.png")
}

func _ready():
	$TextureRect.texture = icons[category]
	
	if(has_node("ItemIcon")):
		$TextureRect.hide()
	match category:
		Equipment.CATEGORY.WEAPON:
			$TextureRect.tooltip_text = "Weapon slot - Drop a weapon item to equip a weapon"
	
	match mode:
		FRAME_MODE.NORMAL:
			modulate = Color(1, 1, 1)
		FRAME_MODE.SUFFICIENT:
			modulate = Color(0.5, 1.2, 0.5)
			$ItemIcon.modulate = Color(1.6,0.6,1.6)
		FRAME_MODE.INSUFFICIENT:
			modulate = Color(1.2, 0.5, 0.5)
			$ItemIcon.modulate = Color(0.6,1.6,1.6)

func _can_drop_data(_pos, data):
	if disabled:
		return false
	if has_node("ItemIcon"):
		return (data["dragged_item"].item.type == $ItemIcon.item.type) and (Data.items[$ItemIcon.item.type].stackable)
	else:
		return category == Equipment.CATEGORY.ANY or data["equip_category"] == category

func _drop_data(_pos, data):
	var dropped_item = data["dragged_item"]
	dropped_item.dropped()
	attach_item_icon(dropped_item)
	item_added.emit(dropped_item.item)

func attach_item_icon(item_icon):
	add_child(item_icon)
	item_icon.name = "ItemIcon"
	$TextureRect.hide()

func remove_item_icon(item_icon):
	remove_child(item_icon)
	$TextureRect.show()
	item_removed.emit()

func clear():
	remove_child($ItemIcon)
	$TextureRect.show()
