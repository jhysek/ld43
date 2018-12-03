extends Node2D

var paused = false

func _on_Button_pressed():
	$Click.play()
	Jukebox.play()
	LevelControler.start_level()
	
func _on_Button_mouse_entered():
	$Click.play()

func back_to_menu():
	get_tree().change_scene("res://Scenes/Menu.tscn")