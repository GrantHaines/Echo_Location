extends KinematicBody2D

var parent: Player
var current_time


func _ready():
	pass


func copy(owner: Player):
	parent = owner
	current_time = parent.current_frame - parent.record_time
	position = parent.position


func _physics_process(delta):
	if (parent.past_actions.has(current_time)):
		if (parent.past_actions[current_time].has(parent.Actions.MOVE_UP)):
			move_and_slide(Vector2(0, -parent.max_speed))
		if (parent.past_actions[current_time].has(parent.Actions.MOVE_RIGHT)):
			move_and_slide(Vector2(parent.max_speed, 0))
		if (parent.past_actions[current_time].has(parent.Actions.MOVE_DOWN)):
			move_and_slide(Vector2(0, parent.max_speed))
		if (parent.past_actions[current_time].has(parent.Actions.MOVE_LEFT)):
			move_and_slide(Vector2(-parent.max_speed, 0))
	
	current_time += 1
