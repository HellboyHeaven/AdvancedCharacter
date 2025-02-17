extends AdvancedCharacter2D


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
	var input_dir := Input.get_axis("ui_left", "ui_right")
	
	if input_dir:
		local_velocity.x = input_dir * SPEED
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, SPEED)

	local_move()
