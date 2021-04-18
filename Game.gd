extends Node2D


export (PackedScene) var Level1: PackedScene

var current_level


# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(Level1)
	current_level.start_level()


func _physics_process(delta):
	if (current_level != null):
		if (current_level.real_player != null):
			$GameUI/PlayerUI/TextureProgress.value = (1 - current_level.real_player.get_echo_charge()) * $GameUI/PlayerUI/TextureProgress.max_value


func load_level(packed_level):
	# Delete old level
	if (current_level != null):
		current_level.queue_free()
	
	var level = packed_level.instance()
	level.connect("level_won", self, "win_dialog")
	current_level = level
	add_child(level)


func win_dialog():
	var tween = $GameUI/Tween
	$GameUI/WinPanel.visible = true
	$GameUI/WinPanel.modulate.a = 0
	tween.interpolate_property($GameUI/WinPanel, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2, tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.start()


func _on_PlayAgainButton_pressed():
	current_level.clear_level()
	current_level.start_level()
	$GameUI/WinPanel.visible = false


func _on_ExitButton_pressed():
	get_tree().quit()
