extends RigidBody3D


var coelho_path := "Sketchfab_model/071d54f580404c40b6ccabe6e194538b_fbx/Object_2/RootNode/Object_4/Skeleton3D"
var min_speed = 10.0
@onready var start_position := position
@onready var start_basis := global_transform.basis
@export var acceleration := 300.0
@export var max_y := 2.6
@export var max_speed := 100.0
@onready var animation := $Coelho/AnimationPlayer
@onready var skeleton : Skeleton3D = $Coelho.get_node(coelho_path)

func _ready() -> void:
	animation.get_animation("mixamo_com").loop = true
	skeleton.reset_bone_poses()


func _physics_process(delta: float) -> void:
	
	# Close the game if player issues exit action.
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()
	
	# Reset player's position if fell of map or player issues reset action.
	if Input.is_action_just_pressed(&"reset_position") or global_position.y < -6.0:
		position = start_position
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_transform.basis = start_basis
		# We teleported the player on the lines above. Reset interpolation
		# to prevent it from interpolating from the old player position
		# to the new position.
		reset_physics_interpolation()

	# Current moving direction.
	var current_dir := linear_velocity.normalized()

	# Target direction from user input.
	var target_dir := Vector3()
	target_dir.x = Input.get_axis(&"move_left", &"move_right")
	target_dir.z = Input.get_axis(&"move_forward", &"move_back")
	target_dir = target_dir.normalized()
	
	# When reversion direction, apply a strong deacceleration.
	if current_dir.dot(target_dir) < 0:
		var velocity_xz := linear_velocity
		velocity_xz.y = 0.0
		linear_velocity -= velocity_xz * 0.05

	# Apply impulse.
	var impulse = target_dir * acceleration
	apply_central_impulse(impulse * delta)
	
	# Speed limit.
	var vel := linear_velocity
	var speed_xz := Vector2(vel.x, vel.z).length()
	if speed_xz > max_speed:
		var dir_xz := Vector2(vel.x, vel.z).normalized()
		vel.x = dir_xz.x * max_speed
		vel.z = dir_xz.y * max_speed
		linear_velocity = vel
	
	# Cut movement when no input and very slow.
	if target_dir.length() < 0.1 and linear_velocity.length() <  min_speed:
		linear_velocity = Vector3.ZERO
	
	# Stops body from jumping when colliding with others.
	if global_transform.origin.y > max_y:
		# Limitar altura
		var clamped_pos := global_transform.origin
		clamped_pos.y = max_y
		global_transform.origin = clamped_pos
		# Cancelar movimento pra cima
		if linear_velocity.y > 0.0:
			linear_velocity.y = 0.0
	
	# Stops body from rotating from collisions and face moving direction.
	angular_velocity = Vector3.ZERO  # Removes any angular velocity.
	var move_dir := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	if move_dir.length() > 0.1:
		move_dir = move_dir.normalized()
		var new_basis := Basis.looking_at(move_dir, Vector3.UP)
		global_transform.basis = new_basis
	
	# Swithes animations.
	if linear_velocity.length() > 0:
		animation.play("mixamo_com")
	else:
		animation.stop()
		skeleton.reset_bone_poses()
