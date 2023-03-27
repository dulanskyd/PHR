extends KinematicBody2D

var velocity := Vector2(0,0)
var face_direction := 1
var x_dir := 1

export var max_speed: float = 560
export var acceleration: float = 2880
export var turning_acceleration : float = 50000
export var deceleration: float = 3200
export var gravity_acceleration : float = 3840
export var gravity_max : float = 1020
export var jump_force : float = 1400
export var jump_cut : float = 0.25
export var jump_gravity_max : float = 500
export var jump_hang_treshold : float = 2.0
export var jump_hang_gravity_mult : float = 0.1
export var jump_coyote : float = 0.08
export var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false

func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"y": int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true
	}

func _physics_process(delta: float) -> void:
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)
	
	timers(delta)
	apply_velocity()

func apply_velocity() -> void:
	if is_jumping:
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 16), Vector2.UP)

func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	velocity.x += x_dir * accel_rate * delta
func jump_logic(_delta: float) -> void:

	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
	
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		if velocity.y > 0:
			velocity.y -= velocity.y
		velocity.y = -jump_force
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0
func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	if jump_coyote_timer > 0:
		return
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	velocity.y += applied_gravity
func timers(delta: float) -> void:
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta

