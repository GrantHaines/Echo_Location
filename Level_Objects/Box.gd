extends Area2D


const can_pickup = true

var locations: Dictionary = Dictionary()


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("carryable_objects")
	locations[0] = position


func drop(frame):
	locations[frame] = position


func reset_to_time(frame):
	var keys = locations.keys()
	var to_return
	
	for x in keys:
		if (x < frame):
			to_return = locations[x]
		if (x > frame):
			break
	
	position = to_return
	
	locations.clear()
	locations[frame] = position
