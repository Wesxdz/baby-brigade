extends RigidBody2D

export var interpolate_time = 5.0
var interp_perc = 0.0
var time = 0.0
export var attractor_force = 10.0

func _ready():
	set_linear_velocity(Vector2(rand_range(-50, 50), rand_range(-50, -150)))

func _physics_process(delta):
	time += delta
	interp_perc = min(time/interpolate_time, 1.0)

func _integrate_forces(state):
	var attractor = get_node("/root/nodes/hud/drop_attractor")
	var to_attractor = attractor.position - position
	state.set_linear_velocity( (state.linear_velocity * (1.0 - interp_perc)) + (interp_perc * (to_attractor.normalized() * min(to_attractor.length_squared() * 4.0, attractor_force))) )
	if to_attractor.length() < 1.0:
		get_node("/root/nodes/hud/top/pinewood_count").pickup()
		queue_free()
