extends KinematicBody2D

class_name Player

signal echo(player)
signal kill_echo(echo)

enum Actions {MOVE_UP, MOVE_RIGHT, MOVE_DOWN, MOVE_LEFT, ECHO, PICKUP, DROP}
enum PlayerType {REAL, GHOST, ECHO}

const acceleration = 100
const max_speed = 150
const record_time = 60 * 6
const echo_delay = 5

var player_type: int = PlayerType.REAL
var current_frame: int = 0

var echo_frame: int = 0
var echo_location: Vector2 = Vector2()

var past_locations: Dictionary = Dictionary()
var past_actions: Dictionary = Dictionary()
var current_actions: Array = Array()

var next_echo: int = 0

var carrying_item

var ghost_parent_player: Player


func _ready():
	pass


# Create the player at the given location
func start_as_real(start_pos, frame):
	player_type = PlayerType.REAL
	position = start_pos
	echo_location = start_pos
	current_frame = frame
	echo_frame = frame
	next_echo = current_frame + record_time + echo_delay
	past_actions.clear()
	current_actions.clear()


# Initialize this as an echo of the given player object
func echo_from_player(player: Player):
	player_type = PlayerType.ECHO
	current_frame = player.echo_frame
	echo_frame = player.echo_frame
	past_actions = player.past_actions.duplicate()
	past_locations = player.past_locations.duplicate()
	position = player.echo_location


# Initialize as trailing ghost of player
func start_as_ghost(player: Player):
	player_type = PlayerType.GHOST
	current_frame = player.echo_frame
	past_actions = player.past_actions
	past_locations = player.past_locations
	position = player.echo_location
	collision_mask = 0
	
	$AnimatedSprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
	ghost_parent_player = player


func reset_to_time(frame, parent_node):
	# check if we still exist
	if (frame >= echo_frame + record_time):
		emit_signal("kill_echo", self)
	else:
		current_frame = frame
		position = past_locations[frame] if past_locations.has(frame) else Vector2()
		$CollisionShape2D.disabled = false
		visible = true


func _physics_process(delta):
	var move_direction = Vector2()
	
	if (player_type == PlayerType.REAL):
		# Get our move direction from the input
		move_direction = get_movement_input()
		# Pickup/drop actions
		do_item_actions()
		# Save the current actions to past_actions
		save_past_actions()
		save_past_location()
		# Update echo frame
		if (current_frame - echo_frame > record_time):
			echo_frame += 1
		if (Input.is_action_just_pressed("game_action") && current_frame > next_echo):
			emit_signal("echo", self)
	
	elif (player_type == PlayerType.ECHO):
		# Get move direction from past_actions
		move_direction = get_movement_past()
		# Pickup/drop actions
		do_item_actions()
		var end_frame = echo_frame + record_time
		var lifetime = end_frame - echo_frame
		var current_life = current_frame - echo_frame
		$DEBUGLABEL.text = "%d/%d" % [current_life, lifetime]
		$StartTime.text = "%d" % echo_frame
		$AnimatedSprite.modulate.a = 1 - (float (current_life) / lifetime)
		if (current_frame >= end_frame):
			$CollisionShape2D.disabled = true
			visible = false
	
	elif (player_type == PlayerType.GHOST):
		if (ghost_parent_player != null):
			current_frame = ghost_parent_player.echo_frame
		move_direction = get_movement_past()
	
	# For ghost - just in case
	if (player_type == PlayerType.GHOST):
		position = past_locations[current_frame]
	
	# Perform movement
	move_and_slide(move_direction * max_speed)
	animate_sprite(move_direction)
	
	current_frame += 1
	current_actions.clear()


# Save current_actions to past_actions
func save_past_actions():
	# Add actions taken to the past actions history
	if (current_actions.size() > 0):
		past_actions[current_frame] = current_actions.duplicate()
	# Do not record past the time limit
	var min_frame = past_actions.keys().min() if past_actions.keys().size() > 0 else 0
	if (current_frame - min_frame > record_time):
		past_actions.erase(min_frame)


func save_past_location():
	past_locations[current_frame] = position
	var min_frame = past_locations.keys().min() if past_locations.keys().size() > 0 else 0
	if (current_frame - min_frame > record_time):
		past_locations.erase(min_frame)
		min_frame = past_locations.keys().min() if past_locations.keys().size() > 0 else 0
		echo_location = past_locations[min_frame]


func do_item_actions():
	if (player_type == PlayerType.REAL):
		if (Input.is_action_just_pressed("game_pickup") && carrying_item == null):
			pickup_item()
			current_actions.append(Actions.PICKUP)
		elif (Input.is_action_just_pressed("game_pickup") && carrying_item != null):
			drop_carried_item()
			current_actions.append(Actions.DROP)
	elif (player_type == PlayerType.ECHO):
		if (past_actions.has(current_frame)):
			if (past_actions[current_frame].has(Actions.PICKUP)):
				pickup_item()
			elif (past_actions[current_frame].has(Actions.DROP)):
				drop_carried_item()


func pickup_item():
	var items_in_range = $PickupZone.get_overlapping_areas()
	if (items_in_range.size() > 0):
		carrying_item = items_in_range[0]
		get_parent().remove_child(carrying_item)
		$PickedUpSprite.texture = carrying_item.get_node("Sprite").texture
		$PickedUpSprite.visible = true


func drop_carried_item():
	if (carrying_item != null):
		get_parent().add_child(carrying_item)
		$PickedUpSprite.visible = false
		carrying_item.position = position
		carrying_item.drop(current_frame)
		carrying_item = null


# Get the movement direction from current player input
# and save it to current_actions for later
func get_movement_input():
	var direction = Vector2()
	if (Input.is_action_pressed("ui_up")):
		direction += Vector2(0, -max_speed)
		current_actions.append(Actions.MOVE_UP)
	if (Input.is_action_pressed("ui_right")):
		direction += Vector2(max_speed, 0)
		current_actions.append(Actions.MOVE_RIGHT)
	if (Input.is_action_pressed("ui_down")):
		direction += Vector2(0, max_speed)
		current_actions.append(Actions.MOVE_DOWN)
	if (Input.is_action_pressed("ui_left")):
		direction += Vector2(-max_speed, 0)
		current_actions.append(Actions.MOVE_LEFT)
	
	return direction.normalized()


# Get the movement direction from the past_actions array
func get_movement_past():
	var direction = Vector2()
	if (past_actions.has(current_frame)):
		if (past_actions[current_frame].has(Actions.MOVE_UP)):
			direction += Vector2(0, -max_speed)
		if (past_actions[current_frame].has(Actions.MOVE_RIGHT)):
			direction += Vector2(max_speed, 0)
		if (past_actions[current_frame].has(Actions.MOVE_DOWN)):
			direction += Vector2(0, max_speed)
		if (past_actions[current_frame].has(Actions.MOVE_LEFT)):
			direction += Vector2(-max_speed, 0)
	
	return direction.normalized()


func animate_sprite(direction):
	if (direction.x > 0):
		$AnimatedSprite.play("walk_right")
	elif (direction.x < 0):
		$AnimatedSprite.play("walk_left")
	elif (direction.y > 0):
		$AnimatedSprite.play("walk_down")
	elif (direction.y < 0):
		$AnimatedSprite.play("walk_up")
	else:
		$AnimatedSprite.animation = "default"


func get_echo_charge():
	var time_left = next_echo - current_frame
	return float (time_left) / (record_time + echo_delay)
