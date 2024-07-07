extends NinePatchRect

var target_ship: Spaceship
#static var target_graphic_mesh_cache = {}

func _ready():
	hide()
	Client.ship_target_updated.connect(
		func _on_target_changed():
			target_ship = Client.target_ship
			if target_ship:
				var type: ShipData = Data.ships[target_ship.type]
				%TypeName.text = type.name
				%Subtitle.text = type.subtitle
				# TODO
				#image.texture = type.target_graphic
				%Faction.text = Data.factions[target_ship.faction].name
				update() 
				show()
				# TODO: Resize to target size
				target_ship.destroyed.connect(_on_target_ship_exited)
				Client.exited_system.connect(_on_target_ship_exited)
				_update_target_graphic(type)
	)

func _process(delta):
	if is_instance_valid(target_ship):
		update()

func _on_target_ship_exited():
	hide()
	target_ship = null

func update():
	if target_ship:
		var health: Health = target_ship.get_node("Health")
		%Armor.value = (float(health.health) / float(health.max_health)) * %Armor.max_value
		%Shields.value = (float(health.shields) / float(health.max_shields)) * %Shields.max_value

func _update_target_graphic(type: ShipData):
	var ref_gfx = type.scene.instantiate().get_node("Graphics")
	
	$SubViewportContainer/SubViewport/MeshInstance3D.mesh = ref_gfx.mesh
	$SubViewportContainer/SubViewport/MeshInstance3D.transform.basis = ref_gfx.transform.basis
	var aabb = $SubViewportContainer/SubViewport/MeshInstance3D.get_aabb()
	var max_dim = max(aabb.size.x, aabb.size.y, aabb.size.z)
	var reference_dim = 2.0
	var re_scale = reference_dim / max_dim
	$SubViewportContainer/SubViewport/MeshInstance3D.scale = Vector3(re_scale, re_scale, re_scale)
