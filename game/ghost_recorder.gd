extends Spatial

const Ghost = preload("res://asynchronous_ghost.gd")

var time = 0
var frequency = 0.01
var timer = 0.0
var ghost_system

func _ready():
	ghost_system = $"/root/ghost_system"
	ghost_system.save_data = []

func _physics_process(delta):
	time += delta
	timer += delta
	if timer > frequency:
		var event = Ghost.TimeEvent.new()
		event.time = time
		event.effectType = Ghost.Change.TRANSFORM
		event.effect = global_transform
		ghost_system.save_data.push_back(event)
		timer -= frequency


func _on_body_on_sled_crash():
	ghost_system.load_data = ghost_system.save_data
