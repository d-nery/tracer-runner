extends KinematicBody2D

const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 100

var velocity = Vector2()

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movingright = 1

# Dashing
const DASH = 800
const DASH_DISTANCE = 100.0
var dashing = false
var dash_time = DASH_DISTANCE/DASH
var dash_timer = dash_time
var can_dash = true

# Called when the node enters the scene tree for the first time.
func _ready():
	movingright = 1
	var currentScale = self.get_scale()
		
func animate():
	if velocity.x < 0:
		scale.x = scale.y * -1
		movingright = -1
	elif velocity.x > 0:
		scale.x = scale.y
		movingright = 1
		
	if dashing:
		$AnimationPlayer.play("dash")
		return
	
	if is_on_floor():
		if velocity.x == 0:
			if Input.is_action_pressed("ui_down"):
				$AnimationPlayer.play("duck")
			else:
				$AnimationPlayer.play("rest")
			
		else:
			$AnimationPlayer.play("running")
	else:
		if velocity.y < 0:
			$AnimationPlayer.play("jumping")
		else:
			$AnimationPlayer.play("falling")

func _physics_process(delta):
	if dashing:
		dash_timer += delta
	if dash_timer > dash_time:
		dashing = false
	
	if not dashing:
		var walk = WALK_FORCE * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
		if abs(walk) < WALK_FORCE * 0.2:
			velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
			
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	
		velocity.y += gravity * delta
	
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
		if is_on_floor() and Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_SPEED
			
	if Input.is_action_just_pressed("ui_dash"):
		if can_dash:
			velocity.x = DASH * movingright
			dash_timer = 0
			can_dash = false
			dashing = true
			
	can_dash = not dashing

	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	animate()
