extends Control

class_name Crafting

# "Uses the generic term blueprint to refer to recipe/build/whatever"

@onready var blueprint_list = get_node("HBoxContainer/ScrollContainer/Recipes")
@onready var blueprint_detail = get_node("HBoxContainer/Details")
@onready var BlueprintIcon = preload("res://ui/EquipBox.tscn")

var current_blueprint = null
var crafting_level: int = 1

func _ready():
	current_blueprint = _blueprints().values()[0]

func _blueprints():
	# Override with whatever blueprint type list you want to use for this; ex Data.recipes."
	return {}

func rebuild():
	clear(blueprint_list)
	_update_blueprint_selection()
	build_blueprint_list()

func assign(crafting_level_object):
	# Assign a crafting station as our "current" station and use its level
	var bench_level = crafting_level_object.crafting_level()
	var player_level = 1 #Client.player.crafting_level
	crafting_level =  max(bench_level, player_level)
	current_blueprint = _blueprints().values()[0]
	Client.player.get_node("Inventory").updated.connect(_update_blueprint_selection)
	
func unassign():
	# Return to a state of using the player's crafting level
	# used to undo any upping of these vars for a workbench
	crafting_level = 1#Client.player.crafting_level
	current_blueprint = _blueprints().values()[0]

func build_blueprint_list():
	for blueprint_id in _blueprints():
		var blueprint = _blueprints()[blueprint_id]
		if blueprint.require_level <= crafting_level:
			var icon = _get_icon_node(blueprint)
			icon.pressed.connect(
				func _blueprint_selected():
					current_blueprint = _blueprints()[blueprint_id]
					_update_blueprint_selection()
			)
			blueprint_list.add_child(icon)

func _get_icon_node(item):
	var icon_texture = _get_icon_texture(item)
	var icon = TextureButton.new()
	
	icon.texture_disabled = icon_texture
	icon.texture_focused = icon_texture
	icon.texture_hover = icon_texture
	icon.texture_normal = icon_texture
	icon.texture_pressed = icon_texture
	return icon

func _get_icon_texture(_blueprint):
	# Return the icon representing this blueprint.
	# For example if it makes an item, implement a function that returns that
	# item's icon
	return null
	
func _update_blueprint_selection():
	blueprint_detail.get_node("Name").text = _get_product_name(current_blueprint)
	blueprint_detail.get_node("Description").text = _get_product_description(current_blueprint)
	
	%Ingredients.assign(current_blueprint.ingredients)

	%BuildButton.disabled = not _can_craft(current_blueprint)
		
func _get_product_name(_blueprint):
	# Get the name representing the blueprint
	return ""

func _get_product_description(_blueprint):
	# Get the text blurb for the blueprint
	return ""

func clear(list):
	for child in list.get_children():
		list.remove_child(child)

func _can_craft(blueprint):
	if is_instance_valid(Client.player):
		var inventory = Client.player.get_node("Inventory")
		var has_ingredients = inventory.has_ingredients(current_blueprint.ingredients)
		return has_ingredients
	else:
		return false

func _on_build_button_pressed():
	if _can_craft(current_blueprint):
		Client.player.get_node("Inventory").deduct_ingredients(current_blueprint.ingredients)
		_do_craft()

func _do_craft():
	pass
