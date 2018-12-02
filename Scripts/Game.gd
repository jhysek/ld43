extends Node2D

var paused = false
onready var camera = $Player/Player/Camera2D
onready var pause_dialog = $UI/Control/PauseDialog
onready var current_player = $Player

func _ready():
	set_process_input(true)
	
func _input(event):
	if Input.is_action_pressed('ui_cancel'):
		if paused:
			paused = false
			#pause_dialog.hide()
		else:
			paused = true
			#pause_dialog.show()


func finished():
	print("Game finished")
	LevelControler.switch_to_next_level()

func camera_tweened():
	var cam = $Camera2D
	remove_child(cam)
	current_player.add_child(cam)
	cam.position = Vector2(0,0)

func _on_Quit_pressed():
	get_tree().change_scene_to("res://Scenes/Menu.tscn")

func _on_Resume_pressed():
	paused = false
	#pause_dialog.hide()
	
func restart():
	$RestartTimer.start()

func _on_RestartTimer_timeout():
	if current_player.last_body:
		current_player.revive()
		var cam = $Camera2D
		if cam:
			cam.tween_to_position(current_player.position)
	else:
		LevelControler.start_level()