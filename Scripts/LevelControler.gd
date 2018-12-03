extends Node

var levels = [
	"res://Levels/Level01.tscn",
	"res://Levels/Level02.tscn",
	"res://Levels/Level03.tscn",	
]

var current_level = 0

func start_level():
	get_tree().change_scene(levels[current_level])
	
func switch_to_next_level():
	if current_level < levels.size() - 1:
		current_level += 1
		start_level()
	else:
		Jukebox.stop()
		get_tree().change_scene("res://Scenes/Finished.tscn")