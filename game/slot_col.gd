extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, Resource) var items
export var spin_rate = 128.0
var target_position
var click_sfx_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate(Vector2.DOWN * delta * spin_rate)
	if position.y > 32.0:
		if click_sfx_enabled:
			$"../click".play()
		translate(Vector2.UP * 32.0)
		move_child(get_child(3), 0)
		var i = 0
		for child in get_children():
			child.position = Vector2(child.position.x, i * 32)
			i += 1

func stop():
	# snap to nearest 32 pixel over time
	position = Vector2(position.x, 16 + round((position.y - 16)/32)*32.0)
	spin_rate = 0.0
