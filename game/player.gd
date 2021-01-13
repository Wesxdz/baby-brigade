extends RigidBody

export var move_force = 1.0
# Should the left leg be moved forward first?
# Used to swich between legs when starting movement
var start_left = true
var ground_threshold = 1
export var rotate_amount = 1.0
var y_rotation = 0
var raycast
var skeleton
export var max_walk_speed = 3.0
export var hill_tilt = 0.5
#export var min_walk_rate = 0.89
#export var max_walk_rate = 3.0
#var walk_rate = 1.0
#var pos_last_frame
var on_ground = true

# Snow affector
export(float) var snow_radius
export(NodePath) var snow_terrain
var distance_between_samples = 2.0
var last_sample_pos = Vector3.ZERO

var avg_ground_normal = Vector3.UP
export var avg_ground_normal_seconds = 1.0

func _ready():
	last_sample_pos = get_global_transform().origin
	get_node(snow_terrain).get_surface_material(0).set_shader_param("displacement_radius", snow_radius)
	raycast = $skele.get_child(0)
	skeleton = $skele.get_node("Skeleton")
	$anim.set_speed_scale(2.0)

func _integrate_forces(state):
	var walk_velocity = Vector2(linear_velocity.x, linear_velocity.z)
#	var t = walk_velocity.length()/max_walk_speed
#	walk_rate = min_walk_rate * (1-t)
#	$anim.set_speed_scale(walk_rate)
#	$skele.look_at(to_global(-linear_velocity), raycast.get_collision_normal())
#	$skele.look_at(to_global(Vector3.FORWARD.rotated(Vector3.UP, y_rotation)), raycast.get_collision_normal())
#	$skele.look_at(to_global(Vector3.FORWARD.rotated(Vector3.UP, y_rotation)), Vector3.UP)
	$skele.look_at(to_global(Vector3.FORWARD.rotated(Vector3.UP, y_rotation)), (avg_ground_normal * hill_tilt) + (Vector3.UP * (1 - hill_tilt)))
	if raycast.is_colliding() and Input.is_action_pressed("move_forward"):
		set_linear_velocity(linear_velocity.project($skele.get_global_transform().basis.x.cross(raycast.get_collision_normal())))
	if walk_velocity.length() > max_walk_speed:
		walk_velocity = walk_velocity.normalized() * max_walk_speed
		set_linear_velocity(Vector3(walk_velocity.x, linear_velocity.y, walk_velocity.y))
#	if !Input.is_action_pressed("move_forward"):
#		var y = linear_velocity.y
#		linear_velocity *= 0.90
#		linear_velocity.y = y
#	pos_last_frame = get_global_transform().origin

func _physics_process(delta):
#	print(linear_velocity)
	if Input.is_action_pressed("rotate_right"):
		y_rotation += delta * -rotate_amount
#		$skele.rotate(get_global_transform().basis.y, delta * -rotate_amount)
	if Input.is_action_pressed("rotate_left"):
		y_rotation += delta * rotate_amount
#		$skele.rotate(get_global_transform().basis.y, delta * rotate_amount)
	if Input.is_action_pressed("move_forward"):
		if $anim.current_animation != "walk":
			$anim.play("walk")
			if !start_left:
				$anim.seek(0.99)
	
func step_forward():
	if Input.is_action_pressed("move_forward"):
		if on_ground:
			$wander.pitch_scale = 0.9 + rand_range(0.0, 0.2)
#			$wander.stream = load("audio/grass-" + str(round(rand_range(0, 1))) + ".wav")
			$wander.play()
			var force_dir = $skele.get_global_transform().basis.x.cross(raycast.get_collision_normal())
#			var force_dir = $skele.get_global_transform().basis.z
			apply_central_impulse(force_dir * move_force)
			start_left = !start_left
		#TODO Max velocity
	else:
		$anim.play("idle001")
		
func _process(delta):
	on_ground = raycast.is_colliding() and (raycast.get_global_transform().origin - raycast.get_collision_point()).length_squared() < ground_threshold
	if delta < avg_ground_normal_seconds:
		var percent_adjust = delta/avg_ground_normal_seconds
		avg_ground_normal -= avg_ground_normal * percent_adjust
		avg_ground_normal += raycast.get_collision_normal() * percent_adjust
	var snow = get_node(snow_terrain)
	snow.get_surface_material(0).set_shader_param("displacement_pos", get_global_transform().origin)
	var sample_dist = (last_sample_pos - get_global_transform().origin).length()
	if sample_dist >= distance_between_samples:
		snow.add_sample(get_global_transform().origin, snow_radius)
		last_sample_pos = get_global_transform().origin



func _on_korean_body_entered(body):
	pass # Replace with function body.


func _on_korean_body_exited(body):
	pass # Replace with function body.
