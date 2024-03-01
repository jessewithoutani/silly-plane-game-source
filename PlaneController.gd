extends RigidBody3D

@onready var propeller : Node3D = $Propeller
@onready var camera : Camera3D = $Camera3D
@onready var _throttle : TextureProgressBar = $Camera3D/Control/Throttle
@onready var fard_clouds : CPUParticles3D = $FardClouds
@onready var wheel_collider = $WheelCollision

var throttle : float = 0.0
var throttle_influence : float = 0.0
var pitch = 0.0
var yaw = 0.0

const THROTTLE_TO_TILT = 0.25
const ROTATIONAL_SPEED = 750
const ROTATIONAL_VEL_CLAMP = PI/6

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_R): get_tree().reload_current_scene()
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var mouse_speed = get_mouse_speed()
	
	var basis = get_global_transform().basis
	var forward = -basis.z
	var backward = basis.z
	var left = -basis.x
	var right = basis.x
	var up = basis.y
	
	throttle += Input.get_axis("throttle_down", "throttle_up") * delta * 1.0
	throttle = clamp(throttle, 0.0, 1.0)
	
	propeller.rotation_degrees.z += delta * 800 * throttle
	
	pitch = mouse_speed.y
	yaw = mouse_speed.x
	
	if throttle > 0 && throttle_influence == 0.0:
		#angular_velocity.y = -yaw * delta * 90 * throttle
		
		#linear_velocity += forward.rotated(Vector3.RIGHT, pitch * delta * deg_to_rad(120))
		
		linear_velocity = forward * throttle * 7.5 + pitch * Vector3.UP * 0.5
		
		#transform.basis = transform.basis.rotated(Vector3.UP, delta * yaw * ROTATIONAL_SPEED)
		#transform.basis = transform.basis.rotated(right, delta * pitch * ROTATIONAL_SPEED)
		#rotation_degrees.z = yaw * 70
		
		#var new_right = forward.cross(Vector3.UP)
		#apply_torque(
			#new_right.cross(yaw * ROTATIONAL_SPEED * Vector3.FORWARD * delta))
		apply_torque(up * yaw * ROTATIONAL_SPEED * delta)
		apply_torque(
			forward.cross(pitch * ROTATIONAL_SPEED * Vector3.UP * delta))
		angular_velocity.z = 0
		angular_velocity = angular_velocity.clamp(
			-ROTATIONAL_VEL_CLAMP * Vector3.ONE, 
			ROTATIONAL_VEL_CLAMP * Vector3.ONE)
		#rotation_degrees.z = yaw * 70
		
	throttle_influence -= delta
	throttle_influence = clamp(throttle_influence, 0.0, 5.0)
	
	#fard_clouds.emitting = throttle > 0
	_throttle.value = throttle
	
	camera.global_position = camera.global_position.lerp(
		position + Vector3.UP * 0.75 + backward * (2.5 + throttle * 0.5), 0.1)
	camera.look_at(position + Vector3.UP * 0.75)
	camera.fov = 75 + throttle * 10
	
func _body_entered():
	if linear_velocity.length() > 1.0:
		throttle_influence += 0.7
		
func _integrate_forces(state):
	if throttle > 0 && throttle_influence == 0.0:
		rotation_degrees.x = clamp(rotation_degrees.x, -45, 45)
		angular_velocity = lerp(angular_velocity, Vector3.ZERO, 0.2)
		rotation_degrees.z = lerp(rotation_degrees.z, yaw * 50 * throttle, 0.05)

func get_mouse_speed() -> Vector2:
	var viewport = get_viewport()
	if not viewport:
		return Vector2.ZERO
	var screen_center = viewport.size * 0.5
	var displacment = screen_center - get_viewport().get_mouse_position()
	displacment.x /= screen_center.x
	displacment.y /= screen_center.y
	return displacment
