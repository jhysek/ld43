extends Area2D

onready var game = get_node("/root/Game")

func _on_Exit_body_entered(body):
	if body.controlled:
		game.finished()