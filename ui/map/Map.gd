extends Control

@onready var movement = get_node("MarginContainer/NinePatchPanel/MarginContainer2/Panel/Movement")
var reveal = true
var dragging = false
var link_assoc_buckets = {}
var long_link_assoc_buckets = {}
var hyperlink_assoc_buckets = {}

var hypergate_available_systems = []

@onready var circle_class = preload("res://ui/map/system.tscn")
@onready var lane_class = preload("res://ui/map/hyperlane.tscn")
var all_hypegate_links = []
var hypergate_links_visible: bool = false

@onready var mode = $MarginContainer/NinePatchPanel/MarginContainer2/Panel/VBoxContainer/Mode

var temp_nodes = []

func _ready():
	_populate_mode_dropdown()
	_generate_map_nodes()
	Client.system_selection_updated.connect(self.hypergate_jump_selection)
	
func _populate_mode_dropdown():
	for item in [
		"Biome",
		"Disposition",
		"Distance from core",
		"Faction",
		"Faction Seeds",
		"Quadrant"
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
		update_link_assoc_bucket(lane, link_assoc_buckets)
	for i in Procgen.longjumps:
		var long_lane = lane_class.instantiate()
		long_lane.data = i
		long_lane.type = Hyperlane.TYPE.LONG
		if not (Cheats.explore_all and Cheats.longjump_enabled):
			long_lane.hide()
		movement.add_child(long_lane)
		update_link_assoc_bucket(long_lane, long_link_assoc_buckets)
	for i in Procgen.hypergate_links:
		var gate_lane = lane_class.instantiate()
		gate_lane.data = i
		gate_lane.type = Hyperlane.TYPE.WARPGATE
		gate_lane.hide()
		movement.add_child(gate_lane)
		update_link_assoc_bucket(gate_lane, hyperlink_assoc_buckets)
		all_hypegate_links.append(gate_lane)
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

func update_link_assoc_bucket(link: Hyperlane, buckets: Dictionary):
	for system_id in [link.data.lsys, link.data.rsys]:
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
	#if not Client.longjump_enabled():
	#	return
	if system_id in long_link_assoc_buckets:
		for link in long_link_assoc_buckets[system_id]:
			if (Cheats.longjump_enabled or
				Procgen.systems[link.data.lsys].longjump_enabled or
				Procgen.systems[link.data.rsys].longjump_enabled
			):
				link.show()
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

func assign_hypergate(links):
	for link in hyperlink_assoc_buckets[Client.current_system_id()]:
		link.show()
		temp_nodes.append(link)
		var other = link.data.lsys
		if link.data.lsys == Client.current_system_id():
			other = link.data.rsys
		
		if not Procgen.systems[other].explored:
			var other_circle = movement.get_node(other)
			other_circle.show()
			temp_nodes.append(other_circle)
		
		hypergate_available_systems.append(other)
	
func unassign():
	for link in temp_nodes:
		link.hide()
	temp_nodes = []
	
	hypergate_available_systems = []
	
func hypergate_jump_selection():
	if Client.selected_system in hypergate_available_systems:
		get_tree().get_root().get_node("Main/UI/").toggle_map()
		Client.change_system()

func toggle_show_all_hypergate_lanes():
	for link in all_hypegate_links:
		if hypergate_links_visible:
			link.hide()
		else:
			link.show()
	hypergate_links_visible = not hypergate_links_visible
	return hypergate_links_visible
