extends Area2D

export var MOTION_SPEED = 1500
export var direction = Vector2(-1, 0)

var from

func _ready():
	set_physics_process(true)
	
func _physics_process(delta):
	position += direction * MOTION_SPEED * delta

func _on_Bullet_body_entered(body):
	queue_free()
	if body.is_in_group("Killable") and body != from and !body.dead:
		body.die()

func _on_Timer_timeout():
	queue_free()