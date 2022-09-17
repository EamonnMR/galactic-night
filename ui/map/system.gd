extends Control

# export var system_name: String = "Name"
export var system_id: String

var data: SystemData

func _ready():
	data = Procgen.systems[system_id]
	$Label.text = data.name
	rect_position = data.position
	update()

func clicked():
	Client.map_select_system(system_id, self)
	update()

func update():
	$circle.update()
	if data.explored or Cheats.explore_all:
		$Label.show()
	else:
		$Label.hide()
func _on_Button_pressed():
	clicked()
