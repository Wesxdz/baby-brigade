extends Node

class Despawn:
	var time
	var node

var shine_prefab = preload("res://touch_fx.tscn")
var touches = {}
var despawn = []

func _process(delta):
	for de in despawn:
		de.time -= delta
		if de.time <= 0.0:
			de.node.queue_free()

func _input(event):
	# Add or free shine fx
	if event is InputEventScreenTouch:
		if event.pressed:
			var shine = shine_prefab.instance()
			add_child(shine)
			shine.position = event.position
			touches[event.index] = shine
		else:
			var de = Despawn.new()
			de.time = 1000
			de.node = touches[event.index]
			de.node.emitting = false
			despawn.append(de)
			touches.erase(event.index)
	elif event is InputEventScreenDrag:
		touches[event.index].position = event.position
