extends XROrigin3D

# --- USTAWIENIA ---
@export var move_speed: float = 3.0
@export var turn_speed: float = 2.5
# Ważne: Deadzone 0.2 eliminuje minimalne drgania, które powodują "wieczne kręcenie"
@export var deadzone: float = 0.2

@onready var left_ctrl: XRController3D = $LeftController
@onready var right_ctrl: XRController3D = $RightController
@onready var xr_camera: XRCamera3D = $XRCamera3D

# --- FUNKCJA HYBRYDOWA ---
# Sprawdza nowoczesny standard ORAZ stary standard.
# Wybiera ten wektor, który jest silniejszy (czyli ten, który aktualnie działa).
func get_hybrid_input(ctrl: XRController3D) -> Vector2:
	var v_modern = ctrl.get_vector2("primary_2d_axis")
	var v_legacy = ctrl.get_vector2("thumbstick")
	
	# Jeśli nowoczesny działa, bierzemy nowoczesny
	if v_modern.length() > v_legacy.length():
		return v_modern
	# W przeciwnym razie bierzemy stary (thumbstick)
	return v_legacy

func _process(delta: float) -> void:
	if not xr_camera: return

	# --- 1. CHODZENIE (LEWA RĘKA) ---
	var input_move = get_hybrid_input(left_ctrl)
	
	if input_move.length() > deadzone:
		var forward = -xr_camera.global_transform.basis.z
		var right = xr_camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		
		var move_dir = (forward.normalized() * input_move.y) + (right.normalized() * input_move.x)
		global_position += move_dir * move_speed * delta

	# --- 2. OBRACANIE (PRAWA RĘKA) ---
	var input_turn = get_hybrid_input(right_ctrl)
	
	# Tutaj był problem z kręceniem. Teraz sprawdzamy deadzone PRZED czymkolwiek innym.
	if abs(input_turn.x) > deadzone:
		rotate_y(-input_turn.x * turn_speed * delta)
	else:
		# Jeśli gałka jest w strefie martwej (czyli puszczona), 
		# kod po prostu nic nie robi = brak obrotu.
		pass
