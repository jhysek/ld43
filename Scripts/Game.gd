extends Node2D

var paused = false
onready var camera = $Player/Player/Camera2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func finished():
	print("Game finished")
