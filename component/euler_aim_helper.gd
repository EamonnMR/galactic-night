extends RemoteTransform3D

var unrotated_position: Node3D = null

# aim point: Global coordinates of the thing to aim at
# Returns a Vector2 representing yaw and pitch to pose at that target
# See:
# https://www.reddit.com/r/godot/comments/p2v6av/quaterionlookrotation_equivalent/
# Called when the node enters the scene tree for the first time.

func _ready():
	unrotated_position = Node3D.new()
	call_deferred("_add_position_tracker")

func _add_position_tracker():
	unrotated_position.name = "PositionFor" + name
	# Entire skeleton is the parent, not the bone
	get_node("../").get_parent().add_child(unrotated_position)
	print("Position For Path3D: ", unrotated_position.get_path())
	remote_path = unrotated_position.get_path()

func _exit_tree():
	unrotated_position.queue_free()

func get_euler_aim(aim_point: Vector2) -> Vector2:
	# aim point: Global coordinates of the thing to aim at
	# Returns a Vector2 representing yaw and pitch to pose at that target
	# See:
	# https://www.reddit.com/r/godot/comments/p2v6av/quaterionlookrotation_equivalent/
	var local_point = unrotated_position.to_local(aim_point)
	# var local_point = get_parent().to_local(aim_point)
	# TODO Ballistic calculation goes here
	var euler = Transform3D.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler()
	return Vector2(euler.x, euler.y)
