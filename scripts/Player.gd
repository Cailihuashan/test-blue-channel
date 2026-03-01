extends CharacterBody3D

enum State { FLYING, WALKING }
var current_state = State.FLYING
var has_key = false

@export var SPEED = 10
@export var ACCEL = 10.0
@export var GRAVITY = 20.0
@export var FRICTION = 4.0
@export var MOUSE_SENSITIVITY = 0.002

@onready var camera = $Neck/Camera3D
@onready var detector = $Detector
@export_range(0, 1) var flight_loss_chance: float = 0.3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	detector.body_entered.connect(_on_city_entered)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	match current_state:
		State.FLYING:
			handle_flying(input_dir, delta)
		State.WALKING:
			handle_walking(input_dir, delta)
			handle_random_fall(delta) 

	move_and_slide()

	if global_position.y < -100.0:
		get_tree().reload_current_scene()

func _on_city_entered(_body):
	if current_state == State.FLYING:
		if randf() < flight_loss_chance:
			current_state = State.WALKING
			set_collision_mask_value(2, true) 

func handle_flying(input_dir, delta):
	var vertical_input = Input.get_axis("down", "up")
	var direction = (camera.global_basis * Vector3(input_dir.x, vertical_input, input_dir.y)).normalized()
	if direction:
		velocity = velocity.lerp(direction * SPEED, 10.0 * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, FRICTION * delta)

func handle_walking(input_dir, delta):
	velocity.y -= GRAVITY * delta
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(89), deg_to_rad(89))

func handle_random_fall(_delta):
	if randf() < 0.001: 
		set_collision_mask_value(2, false)
