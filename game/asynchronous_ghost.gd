extends Spatial

enum Change {
	TRANSFORM,
}

class TimeEvent:
	var time : float
	var effectType
	var effect
	
# A series of events occuring sequentially
var ghost_system
var time = 0
var index = 0

func _ready():
	ghost_system = $"/root/ghost_system"
	if ghost_system.load_data.empty():
		queue_free()

func _physics_process(delta):
	time += delta
	while index < ghost_system.load_data.size() and time >= ghost_system.load_data[index].time:
		sim_event(ghost_system.load_data[index])
		index += 1
		
func sim_event(event):
	if event.effectType == Change.TRANSFORM:
		transform = event.effect
