extends ColorRect

export var particle_speed : float = 0.1

onready var particles : Node = get_node("../viewport/CPUParticles2D")

var _old_mouse_pos : Vector2
var _e_v : Vector2 = Vector2(0.0, 0.0)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			particles.emitting = true
			_old_mouse_pos = get_global_mouse_position()/$"/root/nodes/hud".hud_scale.x - $"../viewport".size / 2.0 - $"../viewport".size/$"/root/nodes/hud".hud_scale.x
		else:
			particles.emitting = false


func _physics_process(delta : float):
	var mouse_pos : Vector2 = get_global_mouse_position()/$"/root/nodes/hud".hud_scale.x - $"../viewport".size / 2.0 - $"../viewport".size/$"/root/nodes/hud".hud_scale.x
	var v : Vector2 = (mouse_pos - _old_mouse_pos)
	_e_v = lerp(_e_v, v, 0.5)
	var s : float = _e_v.length() / delta
	if particles.emitting:
		particles.emission_points[0] = mouse_pos
		particles.emission_normals[0] = _e_v.normalized()
		particles.initial_velocity = particle_speed * s
		particles.tangential_accel = (randf() - 0.5) * 10.0

	_old_mouse_pos = mouse_pos
