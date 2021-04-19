extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_music():
	yield(get_tree().create_timer(1.0), "timeout")
	$Music.play()


func play_box_pickup():
	$BoxPickup.play()


func play_button_press():
	$Button.play()


func _on_Music_finished():
	yield(get_tree().create_timer(5.0), "timeout")
	start_music()
