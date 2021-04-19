extends "res://Level/Level.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Door3.register_key($Button3)
	$Door.register_key($Button2)
	$Elevator.register_key($Button)
	$Door2.register_key($Button3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
