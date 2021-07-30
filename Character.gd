extends KinematicBody

export var gravity : int = -12
export var speed : int = 4
export var jump_speed : int = 6
export(float, 0.01, 1) var mouse_sens : float = 0.05

onready var camera : Spatial = $CameraOrbit

var velocity : Vector3 = Vector3()
var jump : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_input() -> void:
#	Handle input and set velocity accordingly
	var vy = velocity.y
	velocity = Vector3()
	if Input.is_action_pressed("move_forward"):
		velocity += -transform.basis.z * speed
	if Input.is_action_pressed("move_back"):
		velocity += transform.basis.z * speed
	if Input.is_action_pressed("strafe_right"):
		velocity += transform.basis.x * speed
	if Input.is_action_pressed("strafe_left"):
		velocity += -transform.basis.x * speed
	velocity.y = vy
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-90), deg2rad(90))
