extends RigidBody

export(float) var max_air_damp = 0.5
export(float) var air_damp_acceleration = 0.15
export(float) var ground_damp_deccelearation = 15.0
export(float) var turn_strength = 4000.0
export(float) var twist_strength = 2400.0
export(float) var lean_strength = 1000.0
var sled_ragdoll_prefab = preload("res://sled_ragdoll.tscn")
var avg_basis_z
var track_basis_time = 0.5
var on_ground_last = false
var touch_horizontal = 0.0
export(float) var base_max_speed = 30
export(float) var max_speed_increase_per_distance = 0.02
export(float) var meter_conversion = 0.1
var played_dist_reward = false
var default_grav = Vector3(0.0, 1.0, 0.0) * -9.8 * 10.0

signal on_sled_crash

func _ready():
	avg_basis_z = transform.basis.z;
	
func _process(delta):
	var dist = floor(abs(translation.y) * meter_conversion)
	if dist > 0 and int(dist) % 100 == 0:
		if not played_dist_reward:
			$"../../reward".play()
			played_dist_reward = true
	else:
		played_dist_reward = false
	$"/root/nodes/box/ui/hud/distance".set_text(str(dist))

func _physics_process(delta):
	var horizontal = touch_horizontal
	horizontal += Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
#	print(horizontal)
	add_torque(transform.basis.y * horizontal * delta * turn_strength)
	avg_basis_z = transform.basis.z * min(1.0, delta/track_basis_time) + avg_basis_z * max(0.0, (track_basis_time - delta))/track_basis_time
#	if get_colliding_bodies().size() > 0:
#		linear_damp = max(0.0, linear_damp - delta * ground_damp_deccelearation)
#	else:
#		linear_damp = min(max_air_damp, linear_damp + delta * air_damp_acceleration)
	var roll = Input.get_action_strength("roll_right") - Input.get_action_strength("roll_left")
	add_torque(transform.basis.z * roll * delta * twist_strength)
	add_central_force(Vector3.LEFT * roll * delta * 1500)
	var vertical = Input.get_action_strength("lean_forward") - Input.get_action_strength("lean_back")
	add_torque(transform.basis.x * vertical * delta * lean_strength)

func _input(event):
	var half_width = get_viewport().size.x/2
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_horizontal = -(half_width - event.position.x)/half_width
		else:
			touch_horizontal = 0.0

func _integrate_forces(state):
	if translation.y > -50:
		state.add_force(default_grav, Vector3.ZERO) # custom gravity
	else:
		var gravity = translation
		gravity.y = 0
		gravity = gravity.normalized()
		gravity.y = 1.0 # slope of 45 degrees
		gravity = gravity.normalized()
		state.add_force(gravity * -9.8 * 10.0, Vector3.ZERO)
	
	var glide = linear_velocity
#	var ground = get_world().direct_space_state.intersect_ray($ground_check.global_transform.origin, $ground_check.global_transform.origin + $ground_check.cast_to)
	var ground = get_world().direct_space_state.intersect_ray($ground_check_start.global_transform.origin, $ground_check_end.global_transform.origin)
	var query_right = PhysicsShapeQueryParameters.new()
	query_right.shape_rid = $right_bar.shape.get_rid()
	query_right.transform = $right_bar.global_transform
	var right_points = get_world().direct_space_state.collide_shape(query_right).size()
	$trail_right.emitting = right_points > 2
	var query_left = PhysicsShapeQueryParameters.new()
	query_left.shape_rid = $left_bar.shape.get_rid()
	query_left.transform = $left_bar.global_transform
	var left_points = get_world().direct_space_state.collide_shape(query_left).size()
	$trail_left.emitting = left_points > 2
	var on_ground = right_points + left_points > 4
	if on_ground != on_ground_last:
		if on_ground:
			$snow_land.play()
			$snow_loop.play()
		else:
			$snow_loop.stop()
			$snow_leave.play()
	on_ground_last = on_ground
#	print(ground)
	if ground.size() > 0:
		var y = linear_velocity.y
		var dist = (transform.basis.z - avg_basis_z).length_squared() * 10.0
		var percent = clamp(dist, 0.0, 1.0)
		glide = linear_velocity.project(linear_velocity * percent + transform.basis.z * (1.0 - percent))
#		glide.y = y
	var glide_limit = glide.normalized() * (base_max_speed + (abs(translation.y)) * max_speed_increase_per_distance)
	if abs(glide.x) > abs(glide_limit.x):
		glide.x = glide_limit.x
	if abs(glide.y) > abs(glide_limit.y):
		glide.y = glide_limit.y
	if abs(glide.z) > abs(glide_limit.z):
		glide.z = glide_limit.z
	set_linear_velocity(glide)


func _on_body_body_entered(body):
	print("Body!")
	if body.is_in_group("obstacle"):
		print("Break sled!")
		emit_signal("on_sled_crash")
		var sled_ragdoll = sled_ragdoll_prefab.instance()
		sled_ragdoll.transform = transform
		var crash = (10.0 + linear_velocity.length()) * Vector3.UP + linear_velocity
		sled_ragdoll.get_node("body_front").set_linear_velocity(crash)
		sled_ragdoll.get_node("body_back").set_linear_velocity(crash)
		get_parent().add_child(sled_ragdoll)
		$"/root/nodes/gameplay/fail".play()
		$"/root/nodes/box/ui/hud/end_panel".visible = true
		queue_free()


func _on_Area_body_entered(body):
	if body.is_in_group("snowman"):
		print("Slow down!!!")
		$hit_snowman.play()
		body.queue_free()
		linear_velocity /= 2.0
