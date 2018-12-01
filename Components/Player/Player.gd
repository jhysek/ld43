extends KinematicBody2D

export var GRAVITY = 40 * 60
export var SPEED   = 30000
export var JUMP_SPEED  = -850
export var WALL_GRAVITY_THROTLING = 0.05
export var controlled = false
export var can_fly = false
export var can_shoot = false

onready var ray_left = $BottomRayLeft
onready var ray_right = $BottomRayRight
onready var ray_front = $RayFront

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var game = get_node("/root/Game")
onready var progress = $ProgressBar

var motion = Vector2(0,0)
var posessing = false
var posess_timeout = 1
var posessable_enemy
var after_posession_timeout = 0

func _ready():
	set_physics_process(true)

func start_posessing():
	posessing = true
	$PosessArea.monitoring = true
	posess_timeout = -1
	progress.value = 0
	progress.max_value = 2000
	anim.play('StartPosessing')

	
func stop_posessing():
	posessing = false
	$PosessArea.monitoring = false
	progress.hide()
	anim.play('StopPosessing')
	

func controlled_process(delta):
	var in_air = !ray_left.is_colliding() and !ray_right.is_colliding()
	
	if !posessing:
		if not in_air and Input.is_action_pressed("ui_up"):
			in_air = true
			anim.play("Jump")
			#$Sfx/Jump.stop()
			#$Sfx/Jump.play()
			motion.y = JUMP_SPEED
	
		if Input.is_action_pressed('ui_right'):
			if not in_air and anim.current_animation != "WalkRight":
             anim.play("WalkRight")
			motion.x = min(motion.x + SPEED * delta, SPEED * delta)
			sprite.scale.x = 1
		
		if Input.is_action_pressed('ui_left'):
			if not in_air and anim.current_animation != "WalkLeft":
				anim.play("WalkLeft")
			motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
			sprite.scale.x = -1
			
		elif !Input.is_action_pressed('ui_right'):
			if !in_air and anim.current_animation != "Idle":
				anim.play("Idle")
				
			motion.x = 0
	
		if Input.is_action_pressed('ui_accept'):
			start_posessing()
	else:
		motion.x = 0
		
		if !Input.is_action_pressed('ui_accept'):
			stop_posessing()	
		
		
func _physics_process(delta):
	if game.paused:
		return
		
	motion.y += GRAVITY * delta
	
	if controlled:
		if after_posession_timeout > 0:
			after_posession_timeout -= delta
			return
			
		controlled_process(delta)
		
		if posessing and posess_timeout >= 0:
			if posessable_enemy:
				posess_timeout -= delta
				progress.value += delta * 1000
				if progress.value >= progress.max_value:
					posess_enemy()
			else:
				stop_posessing()
			
	motion = move_and_slide(motion)


func posess_enemy():
	if posessable_enemy:
		var cam = $Camera2D
		remove_child(cam)
		posessable_enemy.add_child(cam)
		posessable_enemy.remove_from_group("Posessable")
		posessable_enemy.after_posession_timeout = 0.5
		add_to_group("Posessable")
		stop_posessing()
		cam.position = Vector2(0,0)
		posessable_enemy.controlled = true
		controlled = false
		# die

func _on_PosessArea_body_entered(body):
	if body.is_in_group("Posessable"):
		posessable_enemy = body
		progress.show()
		posess_timeout = 2
		print(body)	
