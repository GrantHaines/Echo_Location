extends Area2D

var active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("level_objects")


func _physics_process(_delta):
	var overlapping = get_overlapping_bodies()
	overlapping += get_overlapping_areas()
	if (overlapping != null && overlapping.size() > 0):
		var old = active
		active = true
		$AnimatedSprite.frame = 1
		if (old != active):
			AudioManager.play_button_press()
	else:
		var old = active
		active = false
		$AnimatedSprite.frame = 0
		if (old != active):
			AudioManager.play_button_press()
