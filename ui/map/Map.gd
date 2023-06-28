extends Control

@onready var movement = get_node("MarginContainer/NinePatchPanel/MarginContainer2/Panel/Movement")
var reveal = true
var dragging = false
var link_assoc_buckets = {}
var long_link_assoc_buckets = {}
@onready var circle_class = preload("res://ui/map/system.tscn")
@onready var lane_class = preload("res://ui/map/hyperlane.tscn")

@onready var mode = $MarginContainer/NinePatchPanel/MarginContainer2/Panel/VBoxContainer/Mode

func _ready():
	_populate_mode_dropdown()
	_generate_map_nodes()
	
func _populate_mode_dropdown():
	for item in [
		"Biome",
		"Disposition",
		"Distance from core",
		"Faction",
		"Faction Seeds"
	]:
		mode.add_item(item)
	
func _generate_map_nodes():
	print("Init Map")
	for i in Procgen.hyperlanes:
		var lane = lane_class.instantiate()
		lane.data = i
		lane.name = i.lsys + "_to_" + i.rsys
		if not Cheats.explore_all:
			lane.hide()
		movement.add_child(lane)
		update_link_assoc_bucket(i.lsys, lane, link_assoc_buckets)
		update_link_assoc_bucket(i.rsys, lane, link_assoc_buckets)
	for i in Procgen.longjumps:
		var long_lane = lane_class.instantiate()
		long_lane.data = i
		# Note that we omit adding it to the scene.
		# TODO: Make a different sometimes-shown class for longjumps.
		update_link_assoc_bucket(i.lsys, long_lane, long_link_assoc_buckets)
		update_link_assoc_bucket(i.rsys, long_lane, long_link_assoc_buckets)
	for i in Procgen.systems:
		var circle = circle_class.instantiate()
		circle.system_id = i
		circle.name = i
		if not Cheats.explore_all:
			circle.hide()
		movement.add_child(circle)
	
	for i in Procgen.systems:
		if Procgen.systems[i].explored or Cheats.explore_all:
			update_for_explore(i)
	
	_set_initial_center()
	
func _set_initial_center():
		var position = Procgen.systems[Client.current_system].position * -1
		var mvm: Control = movement
		var size = mvm.size / 2
		mvm.position = position + size
	
func _input(event):
	if event is InputEventMouseButton:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		movement.position += event.relative

func update_link_assoc_bucket(system_id: String, link: Node, buckets: Dictionary):
	if system_id in buckets:
		var bucket = buckets[system_id]
		if not link in bucket:
			bucket.push_back(link)
	else:
		buckets[system_id] = [link]

func update_for_explore(system_id):
	var sys_node = movement.get_node(system_id)
	sys_node.show()
	sys_node.redraw()
	if system_id in link_assoc_buckets:
		for link in link_assoc_buckets[system_id]:
			link.show()
			movement.get_node(link.data.lsys).show()
			movement.get_node(link.data.rsys).show()
	if system_id in long_link_assoc_buckets:
		for link in long_link_assoc_buckets[system_id]:
			# link.show() #Conditionally show these if the player has a good hyperdrive
			movement.get_node(link.data.lsys).show()
			movement.get_node(link.data.rsys).show()

func _update_for_mode_switch():
	for node in movement.get_children():
		if node.has_method("redraw"):
			node.redraw()

func _on_Recenter_pressed():
	_set_initial_center()

func _on_Mode_item_selected(_index):
	_update_for_mode_switch()
