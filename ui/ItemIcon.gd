extends TextureRect

class_name ItemIcon

var item: Inventory.InvItem

var disabled: bool = false

func init(item, in_inventory: bool = false):
	var data: ItemData = item.data()
	self.item = item
	name = "ItemIcon"
	stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	anchor_right = 1
	anchor_bottom = 1
	texture = data.icon
	tooltip_text = data.name + ": " + data.tooltip
	
func init_fake(type, count):
	disabled = true
	var item = Inventory.InvItem.new(type, count)
	init(item)

func _ready():
	update_count()

func update_count():
	if item.count > 1:
		$Count.text = str(item.count)
	else:
		$Count.text = ""

func _get_drag_data(_position):
	if disabled:
		return null
	var drag_texture = TextureRect.new()
	drag_texture.texture = texture
	# drag_texture.expand = true
	drag_texture.size = size
	set_drag_preview(drag_texture)

	return {
		"dragged_item": self,
		"equip_category": item.data().equip_category
	}
	
func dropped():
	get_node("../").remove_item_icon(self)
	
func _on_gui_input(event: InputEvent):
	# Enable double-click equipping
	if "double_click" in event and event.double_click:
		if equippable():
			if in_player_inventory():
				try_equip_item()
			elif equipped_to_player():
				unequip_item()
		
func equippable() -> bool:
	return false

func in_player_inventory() -> bool:
	return get_node("../../")._inventory().is_player_accessable()

func unequip_item():
	return false
	
func try_equip_item():
	breakpoint

func equipped_to_player() -> bool:
	return false
