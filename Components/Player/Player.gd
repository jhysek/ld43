extends KinematicBody2D

export var GRAVITY = 40 * 60
export var SPEED   = 30000
export var JUMP_SPEED  = -950
export var WALL_GRAVITY_THROTLING = 0.05

var motion = Vector2(0,0)

onready var ray_left = $BottomRayLeft
onready var ray_right = $BottomRayRight
onready var ray_front = $RayFront

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var game = get_node("/root/Game")

func _ready():
	set_physics_process(true)
	
func _physics_process(delta):
	if game.paused:
		return
		
	motion.y += GRAVITY * delta
	
	var in_air = !ray_left.is_colliding() and !ray_right.is_colliding()
	
	if not in_air and Input.is_action_pressed("ui_up"):
		#anim.play("Jump")
		#$Sfx/Jump.stop()
		#$Sfx/Jump.play()
		motion.y = JUMP_SPEED
	
	if Input.is_action_pressed('ui_right'):
#		if not in_air and anim.current_animation != "Run":
#             anim.play("Run")
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)
		sprite.flip_h = false
		
	if Input.is_action_pressed('ui_left'):
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		sprite.flip_h = true
		
	elif !Input.is_action_pressed('ui_right'):
		motion.x = 0
	motion = move_and_slide(motion)