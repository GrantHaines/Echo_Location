extends StaticBody2D

var open: bool = true
var keys: Array = Array()


func _ready():
	add_to_group("level_objects")


func _physics_process(_delta):
	check_keys()


func register_key(key):
	keys.append(key)


func open():
	if (!open):
		open = true
		$Collision.disabled = true
		$AnimatedSprite.play("opening")


func close():
	if (open):
		open = false
		$Collision.disabled = false
		$AnimatedSprite.play("closing")


func check_keys():
	var all_active = true
	for x in keys:
		if (!x.active):
			all_active = false
			break
	
	if (all_active):
		open()
	else:
		close()


func reset():
	open = true
