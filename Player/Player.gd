extends KinematicBody2D

class_name Player

enum Actions {MOVE_UP, MOVE_RIGHT, MOVE_DOWN, MOVE_LEFT, ECHO}
enum PlayerType {REAL, GHOST, ECHO}

const acceleration = 100
const max_speed = 200
const friction = 5
const record_time = 60 * 5

var player_type = PlayerType.REAL
var current_frame = 0
var echo_frame = 0
var past_actions: Dictionary = Dictionary()
var current_actions: Array = Array()


func _ready():
	pass


# Initialize this as an echo of the given player object
func echo_from_player(player: Player):
	player_type = PlayerType.ECHO
	current_frame = player.echo_frame
	echo_frame = current_frame
	past_actions = player.past_actions


func _physics_process(delta):
	var move_direction = Vector2()
	
	if (player_type == PlayerType.REAL):
		# Get our move direction from the input
		move_direction = get_movement_input()
		# Add actions taken to the past actions history
		if (current_actions.size() > 0):
			past_actions[current_frame] = current_actions.duplicate()
		# Do not record past the time limit
		var min_frame = past_actions.keys().min() if past_actions.keys().size() > 0 else 0
		if (current_frame - min_frame > record_time):
			past_actions.erase(min_frame)
	elif (player_type == PlayerType.ECHO):
		# Get move direction from past_actions
		move_direction = get_movement_past()
	
	move_and_slide(move_direction * max_speed)
	
	# Update echo frame
	if (current_frame - echo_frame > record_time):
		echo_frame += 1
	
	current_frame += 1
	current_actions.clear()


func get_movement_input():
	var direction = Vector2()
	if (Input.is_action_pressed("ui_up")):
		direction += Vector2(0, -max_speed)
		#move_and_slide(Vector2(0, -max_speed))
		current_actions.append(Actions.MOVE_UP)
	if (Input.is_action_pressed("ui_right")):
		direction += Vector2(max_speed, 0)
		#move_and_slide(Vector2(max_speed, 0))
		current_actions.append(Actions.MOVE_RIGHT)
	if (Input.is_action_pressed("ui_down")):
		direction += Vector2(0, max_speed)
		#move_and_slide(Vector2(0, max_speed))
		current_actions.append(Actions.MOVE_DOWN)
	if (Input.is_action_pressed("ui_left")):
		direction += Vector2(-max_speed, 0)
		#move_and_slide(Vector2(-max_speed, 0))
		current_actions.append(Actions.MOVE_LEFT)
	
	return direction.normalized()


func get_movement_past():
	var direction = Vector2()
	if (past_actions.has(current_frame)):
		if (past_actions[current_frame] == Actions.MOVE_UP):
			direction += Vector2(0, -max_speed)
		if (past_actions[current_frame] == Actions.MOVE_RIGHT):
			direction += Vector2(max_speed, 0)
		if (past_actions[current_frame] == Actions.MOVE_DOWN):
			direction += Vector2(0, max_speed)
		if (past_actions[current_frame] == Actions.MOVE_LEFT):
			direction += Vector2(-max_speed, 0)
	
	return direction.normalized()
