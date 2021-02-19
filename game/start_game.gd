extends Control

var thread
var ready_to_start = false
var indicate_start = false
var gameplay_prefab = null# preload("res://gameplay.tscn")
var gameplay
var hud_prefab = null# preload("res://hud.tscn")
var hud
var game_started = false

func _ready():
	pass
#	thread = Thread.new()
#	thread.start(self, "load_gameplay", "ok")
#
func start_game():
	$"../start_game_sfx".play()
	indicate_start = true
	if ready_to_start:
		begin_game()
		
#func _process(delta):
#	if indicate_start:
#		if ready_to_start:
#			begin_game()

func _input(event):
	if not game_started:
		if event is InputEventMouseButton:
			if event.pressed:
				begin_game()
	
func begin_game():
	game_started = true
	indicate_start = false
	gameplay_prefab = load("res://gameplay.tscn")
	gameplay = gameplay_prefab.instance()
	hud_prefab = load("res://hud.tscn")
	hud = hud_prefab.instance()
	$"/root/nodes/menu/start".visible = false
	$"/root/nodes".add_child(hud)
	$"/root/nodes".add_child(gameplay)
	
func restart_menu():
	$"../hill_name_gen".gen_random_mountain_name()
#	$"/root/start_menu/title".play()
	ready_to_start = false
	gameplay = null
	thread.start(self, "load_gameplay", "ok")
	$"/root/start_menu".visible = true

func load_gameplay(data):
	gameplay_prefab = load("res://gameplay.tscn")
	gameplay = gameplay_prefab.instance()
	hud_prefab = load("res://hud.tscn")
	hud = hud_prefab.instance()
	call_deferred("gameplay_loaded")
	
func gameplay_loaded():
	ready_to_start = true

#func _exit_tree():
#	thread.wait_to_finish()

func restart():
	gameplay = gameplay.instance()
	$"/root".add_child(gameplay)


func _on_course_pressed():
	start_game()
