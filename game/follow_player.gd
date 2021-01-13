extends DirectionalLight

var target

func _ready():
	target = $"../target"
	
func _process(delta):
	if target != null:
		rotation = Vector3(rotation.x, -atan2(target.translation.z, target.translation.x) + PI/2.0, rotation.z)
