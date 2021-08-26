extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var machine = $"../../../machine"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	get_material().set_shader_param("global_mask_offset", Vector2(machine.margin_left, machine.margin_top))
