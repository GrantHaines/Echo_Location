extends "res://Level/Level.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Door.register_key($Button4)
	$Door.register_key($Button5)
	$Door2.register_key($Button3)
	$Door3.register_key($Button6)
	$Door4.register_key($Button)
	$Door4.register_key($Button2)
	$Door5.register_key($Button7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
