extends Node2D

export (PackedScene) var Ghost


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var ghost = Ghost.instance()
	ghost.copy($Player)
	add_child(ghost)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
