extends RigidBody3D


@onready var start_position := position
var ball_owner : RigidBody3D
var ball_free := true
var foot_offset := Vector3(0, 0, 2.5)
var kick_force := 10.0


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed(&"reset_position") or  global_position.y < -6.0:
		reset()
	
	if Input.is_action_just_pressed("kick"):
		kick()
		return
	
	if ball_owner:
		var target_position = ball_owner.global_transform.origin - ball_owner.global_transform.basis.z * foot_offset.z
		target_position.y = global_transform.origin.y
		global_transform.origin = global_transform.origin.lerp(target_position, 0.3)
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player") and ball_free:
		ball_owner = body


func kick():
	if ball_owner:
		var dir := - ball_owner.global_transform.basis.z.normalized()
		var thrust = dir * kick_force
		thrust.y = 2.0
		ball_owner = null
		$KickDisownTimer.start()
		ball_free = false
		apply_central_impulse(thrust)


func _on_kick_disown_timer_timeout() -> void:
	ball_free = true


func reset():
	# Pressed the reset key or fell off the ground.
		position = start_position
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_transform.basis = Basis()
		# We teleported the ball on the lines above. Reset interpolation
		# prevents it from interpolating from the old position
		# to the new position.
		reset_physics_interpolation()
		# Nobody owns the ball.
		ball_owner = null
