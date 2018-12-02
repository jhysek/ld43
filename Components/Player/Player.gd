extends KinematicBody2D

export var GRAVITY = 40 * 70 #40 * 60
export var ANTIGRAVITY = 20 * 70
export var SPEED   = 30000
export var JUMP_SPEED  = -850
export var FLY_FORCE   = -800
export var FLY_SPEED   = 100
export var FIRE_COOLDOWN = 0.1
export var WALL_GRAVITY_THROTLING = 0.05
export var controlled = false
export var can_fly = false
export var can_shoot = false
export var should_die_after_posess = true
export var boundary_left = - 2200
export var boundary_right = 7000
export var boundary_top = -1200
export var boundary_bottom = 2000

onready var ray_left = $BottomRayLeft
onready var ray_right = $BottomRayRight
onready var ray_front = $Sprite/RayFront

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var game = get_node("/root/Game")
onready var progress = $ProgressBar


var patrolling = false
var dead = false
var motion = Vector2(0,0)
var posessing = false
var posess_timeout = 1
var posessable_enemy
var after_posession_timeout = 0
var killable = true
var start_position
var fire_cooldown = 0

var patrol_route = []
var next_patrol_point_idx = 0
var target 
var patrol_movement = Vector2(0,0)
var was_in_air = false
var last_body

var Bullet

func _ready():
	add_to_group("Killable")
	patrolling = has_node("Patrol")
	if patrolling:
		patrol_route = []
		for point in get_node("Patrol").get_children():
			patrol_route.push_front(point.global_position)
		
	if patrol_route.size() == 0:
		patrolling = false
	else:
		target = patrol_route[0]
		position = target

	if can_shoot:
		ray_front.enabled = true
		Bullet = preload("res://Components/Bullet/Bullet.tscn")

	start_position = position
	set_physics_process(true)

func start_posessing():
	posessing = true
	$PosessArea.monitoring = true
	$PosessArea.show()
	if !can_fly:
	  anim.play("Idle")
	posess_timeout = -1
	progress.value = 0
	progress.max_value = 2000
	$PosessArea/AnimationPlayer.play('Start')
	
func stop_posessing():
	posessing = false
	$PosessArea.monitoring = false
	progress.hide()
	$PosessArea/AnimationPlayer.play('Stop')
	
func fire():
	$Sfx/Fire.play()
	var bullet = Bullet.instance()
	game.add_child(bullet)
	bullet.from = self
	bullet.direction = Vector2($Sprite.scale.x, 0)
	bullet.position = $Sprite/Visual/Body/Gun/BulletStart.global_position
	anim.play("Fire")

func patrolling_process(delta):
	motion = Vector2(0,0)
		
	if abs(target.x - position.x) < 20:
		next_patrol_point_idx = (next_patrol_point_idx + 1) % patrol_route.size()
		target = patrol_route[next_patrol_point_idx]
		if target.x >= position.x:
			patrol_movement = Vector2(FLY_SPEED, 0)
			if can_fly:
				anim.play("Fly")
				$Sprite.scale = Vector2(-1, 1)
			else:
				anim.play("WalkRight")
				
		else:
			patrol_movement = Vector2(-FLY_SPEED, 0)
			if can_fly:
				anim.play("Fly")
				$Sprite.scale = Vector2(1, 1)
			else:
				anim.play("WalkLeft")
	else:
		motion = patrol_movement

func controlled_flying_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		motion.y = FLY_FORCE
		anim.play("Flap")
		$Hint.hide()
		
	if !posessing:
		if Input.is_action_pressed('ui_right'):
			motion.x = min(motion.x + SPEED * delta, SPEED * delta)
			sprite.scale.x = -1
		
		if Input.is_action_pressed('ui_left'):
			motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
			sprite.scale.x = 1
		elif !Input.is_action_pressed('ui_right'):
			motion.x = lerp(motion.x, 0, 4 * delta)
		
		if Input.is_action_pressed('ui_down'):
			start_posessing()

	else:
		motion.x = lerp(motion.x, 0, 4 * delta)
		
		if !Input.is_action_pressed('ui_down'):
			stop_posessing()
			
	
func controlled_process(delta):
	var in_air = !ray_left.is_colliding() and !ray_right.is_colliding()
	if was_in_air and !in_air:
		$Sfx/Jump.play()
	was_in_air = in_air
	
	
	if !posessing:
		if not in_air and Input.is_action_pressed("ui_up"):
			in_air = true
			anim.play("Jump")
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
			if !in_air and anim.current_animation != "Idle" and fire_cooldown <= 0:
				anim.play("Idle")
				
			motion.x = 0
	
		if can_shoot and Input.is_action_just_pressed("ui_accept") and fire_cooldown <= 0:
			fire()
			motion.x = -500
			fire_cooldown = FIRE_COOLDOWN
			
		if Input.is_action_pressed('ui_down'):
			start_posessing()
		
	else:
		motion.x = 0
		
		if !Input.is_action_pressed('ui_down'):
			stop_posessing()	
		
		
func _physics_process(delta):
	if game.paused:
		return
		
	motion.y += GRAVITY * delta
	
	if can_fly: 
		motion.y -= ANTIGRAVITY * delta
	
	if fire_cooldown > 0:
		fire_cooldown -= delta
		
	if controlled and not dead:
		if after_posession_timeout > 0:
			after_posession_timeout -= delta
			return
		
		if can_fly:
			controlled_flying_process(delta)
		else:
			controlled_process(delta)
		
		if posessing and posess_timeout >= 0:
			if posessable_enemy:
				posess_timeout -= delta
				progress.value += delta * 1000
				if progress.value >= progress.max_value:
					dead = true
					posess_enemy()
			else:
				stop_posessing()
	elif !dead and patrolling:
		patrolling_process(delta)
		
	if !dead and can_shoot:
		if ray_front.is_colliding():
			var collider = ray_front.get_collider()
			if collider and collider.is_in_group('Killable') and fire_cooldown <= 0:
				fire()
				motion.x = -500
				fire_cooldown = 0.2
					
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
		
	motion = move_and_slide(motion)
				
	position.x = clamp(position.x, boundary_left, boundary_right)
	position.y = clamp(position.y, boundary_top, boundary_bottom)

func die():
	dead = true	
	remove_from_group("Posessable")
	$Sfx/Die.play()
	$PosessArea.hide()
	anim.play("Die")
	$Blood.emitting = true
	var cam = $Camera2D

	if !posessable_enemy and cam:
		remove_child(cam)
		game.add_child(cam)
		cam.position = position
		cam.shake(0.4, 50, 20)
		game.restart()

func posess_enemy():
	dead = true
	stop_posessing()
	die()
	$Camera2D.shake(1.0, 70, 20)
	
	if posessable_enemy:
		posessable_enemy.remove_from_group("Posessable")
		posessable_enemy.after_posession_timeout = 0.5
		add_to_group("Posessable")
		posessable_enemy.last_body = self
		game.current_player = posessable_enemy
		if posessable_enemy.can_fly and posessable_enemy.has_node("Hint"):
			posessable_enemy.get_node("Hint").show()
			
		$Camera2D.tween_to_position(posessable_enemy.position - position)
		posessable_enemy.controlled = true
		controlled = false
	
func revive():
	position = start_position
	dead = false
	anim.play("Idle")
	$Blood.emitting = false

func _on_PosessArea_body_entered(body):
	if body.is_in_group("Posessable"):
		posessable_enemy = body
		progress.show()
		posess_timeout = 2

func camera_tweened():
	var cam = $Camera2D
	remove_child(cam)
	cam.position = Vector2(0,0)
	posessable_enemy.add_child(cam)
	$Blood.queue_free()
