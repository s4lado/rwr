extends CharacterBody3D


@export var xr_origin: XROrigin3D
@export var left_ctrl: XRController3D
@export var right_ctrl: XRController3D
@export var xr_camera: XRCamera3D


@export var move_speed: float = 3.0
@export var turn_speed: float = 2.5
@export var deadzone: float = 0.2


@export var spawn_point: Vector3 = Vector3(0.0, 1.0, 0.0) 


@export var fall_limit: float = -10.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	
	if global_position.y < fall_limit:
		global_position = spawn_point
		velocity = Vector3.ZERO 
	

	
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	var input_move = get_hybrid_input(left_ctrl)
	var input_turn = get_hybrid_input(right_ctrl)

 
	var direction = Vector3.ZERO
	if input_move.length() > deadzone:
		var forward = -xr_camera.global_transform.basis.z
		var right = xr_camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		direction = (forward.normalized() * input_move.y) + (right.normalized() * input_move.x)

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

	
	if abs(input_turn.x) > deadzone:
		xr_origin.rotate_y(-input_turn.x * turn_speed * delta)

func get_hybrid_input(ctrl) -> Vector2:
	if not ctrl: return Vector2.ZERO
	var v_modern = ctrl.get_vector2("primary_2d_axis")
	return v_modern if v_modern.length() > 0 else ctrl.get_vector2("thumbstick")
