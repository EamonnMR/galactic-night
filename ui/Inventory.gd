extends Control

@export var label: String
@export var inventory: NodePath

var inventory_slot = preload("res://ui/EquipBox.tscn")
var item_icon = preload("res://ui/ItemIcon.tscn")

func assign(bound_inventory: Inventory, new_name: String):
	inventory = bound_inventory.get_path()
	label = new_name
	bound_inventory.updated.connect(rebuild)
	rebuild.call_deferred()

func _ready():
	%NameSlot.text = label
	if inventory:
		assign(get_node(inventory), label)
func _clear():
	for child in %GridContainer.get_children():
		%GridContainer.remove_child(child)

func _inventory():
	return get_node(inventory)

func rebuild():
	%NameSlot.text = label
	_clear()
	var inv: Inventory = _inventory()
	if is_instance_valid(inv):
		var max_items = inv.max_items
		for i in range(max_items):
			var slot_container = inventory_slot.instantiate()
			slot_container.item_removed.connect(
				func _on_item_removed():
					_inventory().remove_item_from_slot(i)
			)
			slot_container.item_added.connect(
				func _on_item_added(item):
					_inventory().add(item.type, item.count, i)
			)
			if i in inv.item_slots:
				var item: Inventory.InvItem = inv.item_slots[i]
				var icon = item_icon.instantiate()
				icon.init(item)
				slot_container.add_child(icon)
			%GridContainer.add_child(slot_container)
