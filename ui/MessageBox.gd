extends Label

func _ready():
	Client.message.connect(set_message)

func set_message(message: String):
	# TODO: Sound Effcet
	text = message
	$Timer.start()


func _on_timer_timeout():
	text = ""
