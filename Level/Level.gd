extends Node2D

signal level_won

export (PackedScene) var Player: PackedScene

var real_player: Player
var ghost_player: Player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func start_level(echo_enabled):
	var player = Player.instance()
	real_player = player
	real_player.start_as_real($StartLocation.position, 0)
	real_player.connect("echo", self, "echo")
	real_player.can_echo = echo_enabled
	add_child(real_player)
	
	if (real_player.can_echo):
		var ghost = Player.instance()
		ghost_player = ghost
		ghost_player.start_as_ghost(real_player)
		ghost_player.z_index = -1
		add_child(ghost_player)
	
	$Elevator.connect("player_entered", self, "delete_player")
	$Elevator.connect("finished_descending", self, "win_level")


func clear_level():
	var echoes = get_tree().get_nodes_in_group("echoes")
	for x in echoes:
		x.queue_free()
	
	var objects = get_tree().get_nodes_in_group("level_objects")
	for x in objects:
		if (x.has_method("reset")):
			x.reset()
	
	delete_player()


func win_level():
	delete_player()
	emit_signal("level_won")


func delete_player():
	if (ghost_player != null):
		ghost_player.queue_free()
	if (real_player != null):
		real_player.queue_free()


func echo(player: Player):
	var echoes = get_tree().get_nodes_in_group("echoes")
	for x in echoes:
		x.reset_to_time(player.echo_frame, self)
	
	var echo = Player.instance()
	echo.echo_from_player(player)
	echo.add_to_group("echoes")
	echo.connect("kill_echo", self, "kill_echo")
	add_child(echo)
	player.start_as_real(player.echo_location, player.echo_frame)
	
	# Reset carryables
	var boxes = get_tree().get_nodes_in_group("carryable_objects")
	for x in boxes:
		x.reset_to_time(player.echo_frame)


func kill_echo(echo: Player):
	echo.queue_free()
