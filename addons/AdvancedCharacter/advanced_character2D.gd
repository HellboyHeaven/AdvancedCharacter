extends CharacterBody2D
class_name AdvancedCharacter2D

@export var _step_height : float = 1.0
var parameters = PhysicsTestMotionParameters2D.new()
var result = PhysicsTestMotionResult2D.new()
var was_grounded := false
var local_velocity := Vector2.ZERO

func _init() -> void:
	parameters.margin = safe_margin
	
func _physics_process(delta: float) -> void:
	var rotation = Vector2.UP.angle_to(up_direction)
	transform = Transform2D(rotation, position)
	local_velocity = velocity.rotated(-rotation)
	pass

func local_move():
	_step_up()
	_step_down()
	var rotation = Vector2.UP.angle_to(up_direction)
	velocity = local_velocity.rotated(rotation)
	was_grounded = is_on_floor()
	move_and_slide()

func _step_up():
	var ivelocity = Vector2(local_velocity.x, 0)
	ivelocity = global_transform * ivelocity
	
	var motion_transform = global_transform
	parameters.from = motion_transform
	parameters.motion = ivelocity * get_physics_process_delta_time()
	
	if not PhysicsServer2D.body_test_motion(get_rid(), parameters, result):
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
	if PhysicsServer2D.body_test_motion(get_rid(), parameters, result) == false:
		return
	
	global_transform = global_transform.translated(result.get_travel())
	apply_floor_snap()	

func _move_test(motion_transform: Transform2D, motion : Vector2) -> Transform2D:
	parameters.from = motion_transform
	parameters.motion = motion
	PhysicsServer2D.body_test_motion(get_rid(), parameters, result)
	return motion_transform.translated(result.get_travel())
	
