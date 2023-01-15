extends Node3D

class_name Controller

@onready var parent = get_node("../")

var shooting: bool

var shooting_secondary: bool

var thrusting: bool

var rotation_impulse: float

var braking: bool

var jumping: bool
