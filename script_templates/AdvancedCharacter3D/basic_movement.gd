extends AdvancedCharacter3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	#Add the gravity.
	if not is_on_floor():
		local_velocity += get_gravity() * delta
	


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		local_velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y);
	if direction:
		local_velocity.x = direction.x * SPEED
		local_velocity.z = direction.z * SPEED
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, SPEED)
		local_velocity.z = move_toward(local_velocity.z, 0, SPEED)

	local_move()
