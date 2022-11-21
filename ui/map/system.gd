extends Control

# export var system_name: String = "Name"
@export var system_id: String

var data: SystemData

func _ready():
	data = Procgen.systems[system_id]
	$Label.text = data.name
	position = data.position
	redraw()
	
func clicked():
	Client.map_select_system(system_id, self)
	redraw()

func redraw():
	$circle.queue_redraw()
	if data.explored or Cheats.explore_all:
		$Label.show()
	else:
		$Label.hide()
func _on_Button_pressed():
	clicked()
