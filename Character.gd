extends KinematicBody

export var gravity : int = -12
export var speed : int = 6
export var jump_speed : int = 6
export var air_speed : int = 4
export(float, 0.01, 1) var mouse_sens = 0.05
export(float, -90, 90) var min_camera_angle = -90
export(float, -90, 90) var max_camera_angle = 90

onready var camera : Spatial = $CameraOrbit

var velocity : Vector3 = Vector3()
var jump : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_input() -> void:
#	Handle input and set velocity accordingly
	var vy = velocity.y
	velocity = Vector3()
	var accel = speed if is_on_floor() else air_speed
	if Input.is_action_pressed("move_forward"):
		velocity += -transform.basis.z * accel
	if Input.is_action_pressed("move_back"):
		velocity += transform.basis.z * accel
	if Input.is_action_pressed("strafe_right"):
		velocity += transform.basis.x * accel
	if Input.is_action_pressed("strafe_left"):
		velocity += -transform.basis.x * accel
	velocity = velocity.normalized() * speed
	velocity.y = vy
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta) -> void :
#	Apply velocity calculation to the physics process
	velocity.y += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector3.UP)
	if jump and is_on_floor():
		velocity.y = jump_speed

func _unhandled_input(event) -> void:
#	Translate mouse movement to camera and character model movement
	if event is InputEventMouseMotion:
		rotate_y(-lerp(0, mouse_sens, event.relative.x/10))
		camera.rotate_x(-lerp(0, mouse_sens, event.relative.y/10)) 
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(min_camera_angle), deg2rad(max_camera_angle))
