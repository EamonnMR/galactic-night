extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready():
	Client.money_updated.connect(_update)
	_update()

func rebuild():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update():
	$Label.text = "Money:\n" + str(Client.money) + " cr"
