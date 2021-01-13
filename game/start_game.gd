extends Control

var thread
var gameplay
var ready_to_start = false
var indicate_start = false
var gameplay_prefab = preload("res://gameplay.tscn")
var hud_prefab = preload("res://hud.tscn")

func _ready():
	thread = Thread.new()
	print("Load gameplay")
	thread.start(self, "load_gameplay", "ok")
	
func start_game():
	$"../start_game_sfx".play()
	indicate_start = true
	if ready_to_start:
		begin_game()
		
func _process(delta):
	if indicate_start:
		if ready_to_start:
			begin_game()
	
func begin_game():
	print("Begin game!")
	indicate_start = false
	$"../title_ost".stop()
	$"/root/nodes/box/ui/menu/start".visible = false
	$"../../canvas/background".visible = false
	$"/root/nodes/box/ui".add_child(hud_prefab.instance())
	$"/root/nodes".add_child(gameplay)
	
func restart_menu():
	$"../hill_name_gen".gen_random_mountain_name()
	$"/root/start_menu/title".play()
	ready_to_start = false
	gameplay = null
	thread.start(self, "load_gameplay", "ok")
	$"/root/start_menu".visible = true
	$"/root/start_menu/canvas/background".visible = true

func load_gameplay(data):
	gameplay = gameplay_prefab.instance()
	call_deferred("gameplay_loaded")
	
func gameplay_loaded():
	print("Gameplay loaded!")
	thread.wait_to_finish()
	ready_to_start = true

func _exit_tree():
	thread.wait_to_finish()

func restart():
	gameplay = gameplay.instance()
	$"/root".add_child(gameplay)


func _on_course_pressed():
	start_game()
