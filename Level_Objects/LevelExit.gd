extends StaticBody2D

signal player_entered
signal finished_descending

var locked: bool = false
var reached: bool = false
var keys: Array = Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("level_objects")


func _physics_process(_delta):
	check_keys()


func register_key(key):
	keys.append(key)
	if (!locked):
		lock()


func lock():
	locked = true
	$ClosedCollider.disabled = false
	$OpenCollider.disabled = true
	$AnimatedSprite.play("closing")


func unlock():
	locked = false
	$ClosedCollider.disabled = true
	$OpenCollider.disabled = false
	$AnimatedSprite.play("opening")


func check_keys():
	if (!reached):
		var all_active = true
		for x in keys:
			if (!x.active):
				all_active = false
				break
		
		if (all_active):
			unlock()
		else:
			lock()


func reset():
	reached = false
	$TransparentDoor.visible = false
	$FakePlayer.visible = false
	$AnimatedSprite.animation = "default"
	$AnimatedSprite.playing = false


func _on_ExitRegion_body_entered(body):
	if (body is Player):
		if (body.player_type == body.PlayerType.REAL):
			reached = true
			emit_signal("player_entered")
			$FakePlayer.visible = true
			yield(get_tree().create_timer(0.2), "timeout")
			$TransparentDoor.visible = true
			$TransparentDoor.frame = 0
			$TransparentDoor.play()


func _on_TransparentDoor_animation_finished():
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimatedSprite.play("descending")
	$FakePlayer.visible = false
	$TransparentDoor.visible = false
	yield(get_tree().create_timer(2.5), "timeout")
	emit_signal("finished_descending")
