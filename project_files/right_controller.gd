extends XRController3D

@onready var ray: RayCast3D = $TeleportRay
@onready var marker: MeshInstance3D = $TeleportMarker
var xr_origin: XROrigin3D
var xr_camera: XRCamera3D


var is_aiming: bool = false

func _ready() -> void:
	xr_origin = get_parent() as XROrigin3D
	xr_camera = xr_origin.get_node("XRCamera3D") as XRCamera3D
	marker.visible = false
	
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)

func _process(_delta: float) -> void:
	if is_aiming and ray.is_colliding():
		marker.global_transform.origin = ray.get_collision_point()
		marker.visible = true
	else:
		marker.visible = false

func _on_button_pressed(input_name: String) -> void:
	if input_name == "trigger_click":
		is_aiming = true 

func _on_button_released(input_name: String) -> void:
	if input_name == "trigger_click":
		if is_aiming: 
			teleport_now()
		is_aiming = false 

func teleport_now() -> void:
	if not ray.is_colliding():
		return
	
	
	var target: Vector3 = ray.get_collision_point()
	var origin_tf := xr_origin.global_transform
	var cam_tf := xr_camera.global_transform
	var cam_offset := cam_tf.origin - origin_tf.origin
	
	
	cam_offset.y = 0 

	origin_tf.origin = target - cam_offset
	xr_origin.global_transform = origin_tf
