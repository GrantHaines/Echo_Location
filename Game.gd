extends Node2D


export (PackedScene) var Level1: PackedScene
export (PackedScene) var Level2: PackedScene
export (PackedScene) var Level3a: PackedScene
export (PackedScene) var Level3: PackedScene
export (PackedScene) var Level4: PackedScene
export (PackedScene) var Level5: PackedScene
export (PackedScene) var Level6: PackedScene

const last_level: int = 7

var current_level
var level_number: int = 0
var echo_active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	level_number = 0
	next_level()
	AudioManager.start_music()


func _physics_process(_delta):
	if (Input.is_action_just_pressed("game_reset") && current_level != null):
		current_level.clear_level()
		level_number -= 1
		next_level()
	
	if (current_level != null):
		if (current_level.real_player != null && echo_active):
			$GameUI/PlayerUI/TextureProgress.value = (1 - current_level.real_player.get_echo_charge()) * $GameUI/PlayerUI/TextureProgress.max_value


func next_level():
	level_number += 1
	var can_echo = true
	
	if (level_number > last_level):
		$GameUI/GameOverPanel.visible = true
	else:
		if (level_number == 1):
			load_level(Level1)
			can_echo = false
			$GameUI/GameMessage.text = "Goal: Reach the elevator"
		elif (level_number == 2):
			load_level(Level2)
			can_echo = false
			$GameUI/GameMessage.text = "Press 'E' to pick up boxes"
		elif (level_number == 3):
			load_level(Level3a)
			$GameUI/GameMessage.text = "Press 'Space' to echo"
		elif (level_number == 4):
			load_level(Level3)
			$GameUI/GameMessage.text = "Press 'Space' to echo"
		elif (level_number == 5):
			load_level(Level4)
			$GameUI/GameMessage.text = "Press 'R' to restart the level"
		elif (level_number == 6):
			load_level(Level5)
			$GameUI/GameMessage.text = "Press 'R' to restart the level"
		elif (level_number == 7):
			load_level(Level6)
			$GameUI/GameMessage.text = "Press 'R' to restart the level"
		
		if (can_echo):
			$GameUI/PlayerUI/TextureProgress.visible = true
		else:
			$GameUI/PlayerUI/TextureProgress.visible = false
		
		current_level.start_level(can_echo)
		
		$GameUI/LevelNumber.text = "Level %d" % level_number


func load_level(packed_level):
	# Delete old level
	if (current_level != null):
		current_level.queue_free()
	
	var level = packed_level.instance()
	level.connect("level_won", self, "next_level")
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


func _on_NextLevelButton_pressed():
	next_level()
	$GameUI/WinPanel.visible = false
