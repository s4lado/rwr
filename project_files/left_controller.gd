extends XROrigin3D

@export var move_speed: float = 2.5
@export var deadzone: float = 0.2 # Lekko zwiększyłem, żeby nie "dryfowało"

# Upewnij się, że ścieżki do węzłów są poprawne
@onready var xr_camera: XRCamera3D = $XRCamera3D
@onready var left_ctrl: XRController3D = $LeftController

func _physics_process(delta: float) -> void:
	# Pobieramy wektor z gałki (Input Name to zazwyczaj "primary_2d_axis" w standardzie OpenXR)
	# Jeśli w Twoich ustawieniach Input Map nazywa się "thumbstick", zostaw "thumbstick"
	var input_vector: Vector2 = left_ctrl.get_vector2("primary_2d_axis")
	
	# Deadzone - ignorujemy małe wychylenia
	if input_vector.length() < deadzone:
		input_vector = Vector2.ZERO
		return # Szkoda procesora, jeśli nie ruszamy gałką

	# --- TU JEST MAGIA NAPRAWY ---
	
	# Pobieramy kierunek patrzenia kamery
	var forward_dir: Vector3 = -xr_camera.global_transform.basis.z
	var right_dir: Vector3 = xr_camera.global_transform.basis.x
	
	# "Spłaszczamy" wektory - zerujemy oś Y, żeby nie latać w kosmos
	forward_dir.y = 0
	right_dir.y = 0
	
	# Normalizujemy, żeby ruch na skos nie był szybszy (twierdzenie Pitagorasa)
	forward_dir = forward_dir.normalized()
	right_dir = right_dir.normalized()
	
	# Obliczamy finalny kierunek ruchu
	# input_vector.y odpowiada za przód/tył
	# input_vector.x odpowiada za lewo/prawo (strafe)
	var movement_dir: Vector3 = (forward_dir * input_vector.y) + (right_dir * input_vector.x)
	
	# Przesuwamy gracza
	if movement_dir.length() > 0:
		global_translate(movement_dir * move_speed * delta)
