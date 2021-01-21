extends RigidBody2D

export var interpolate_time = 5.0
var interp_perc = 0.0
var time = 0.0
export var attractor_force = 10.0
var sim_scale = 1.0
var attractor

func _ready():
	attractor = get_node("/root/nodes/hud/top/asmrcoin/icon")
	sim_scale = get_node("/root/nodes/hud").hud_scale.x
	gravity_scale = sim_scale
	print(sim_scale)
	set_linear_velocity(Vector2(rand_range(-50, 50), rand_range(-50, -150)))
	$pine.set_transform($pine.get_transform().scaled(get_node("/root/nodes/hud").hud_scale))

func _physics_process(delta):
	time += delta
	interp_perc = min(time/interpolate_time, 1.0)

func _integrate_forces(state):
	var to_attractor = attractor.get_global_position() + (attractor.get_pivot_offset() * sim_scale) - get_global_transform().origin
	state.set_linear_velocity((state.linear_velocity * (1.0 - interp_perc)) + (interp_perc * (to_attractor.normalized() * min(to_attractor.length_squared() * 4.0, attractor_force))) )
	if to_attractor.length() < 1.0 or time > interpolate_time + 2.0:
		get_node("/root/nodes/hud/top/asmrcoin").pickup()
		queue_free()
