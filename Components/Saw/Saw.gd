extends Area2D

export var ROTATION_SPEED = 900

func _ready():
	set_process(true)
	
func _process(delta):
	rotation_degrees -= ROTATION_SPEED * delta

func _on_Saw_body_entered(body):
	if body.is_in_group("Killable") and !body.dead:
		body.die()