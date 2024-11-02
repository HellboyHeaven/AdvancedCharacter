class_name AdvancedCharacter3D extends CharacterBody3D

@export var _step_height : float = 1.0
var parameters = PhysicsTestMotionParameters3D.new()
var result = PhysicsTestMotionResult3D.new()
var was_grounded := false
var local_velocity := Vector3.ZERO

func _init() -> void:
	parameters.margin = safe_margin
	

func _physics_process(delta: float) -> void:
	var rotation_axis = Vector3.UP.cross(up_direction).normalized()
	var rotation_angle = Vector3.UP.angle_to(up_direction)
	transform.basis = Basis(rotation_axis, rotation_angle)
	local_velocity = transform.basis.inverse() * velocity
	pass


func local_move():
	_step_up()
	_step_down()
	velocity = global_transform.basis * local_velocity
	was_grounded = is_on_floor()
	move_and_slide()
	

func _step_up():
	var ivelocity = Vector3(local_velocity.x, 0, local_velocity.z)
	ivelocity = global_transform.basis * ivelocity
	
	var motion_transform = global_transform
	parameters.from = motion_transform
	parameters.motion = ivelocity * get_physics_process_delta_time()
	
	if not PhysicsServer3D.body_test_motion(get_rid(), parameters, result):
		return
	var remainder = result.get_remainder()
	motion_transform = motion_transform.translated(result.get_travel())
	
	motion_transform = _move_test(motion_transform, up_direction * _step_height)
	motion_transform = _move_test(motion_transform, remainder)
	motion_transform = _move_test(motion_transform, -up_direction * _step_height)
	
	global_transform = motion_transform
	
func _step_down() -> void:
	# Don't step down if we weren't on the ground last physics frame
	if was_grounded == false || local_velocity.y >= 0 || is_on_floor(): return
	
	parameters.from = global_transform
	parameters.motion = -up_direction * _step_height
	
	# Nothing to step down on
	if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == false:
		return
	
	global_transform = global_transform.translated(result.get_travel())
	apply_floor_snap()

	

func _move_test(motion_transform: Transform3D, motion : Vector3) -> Transform3D:
	parameters.from = motion_transform
	parameters.motion = motion
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)
	return motion_transform.translated(result.get_travel())
	
