extends Node

onready var nouns = 'res://hill-types.txt'
onready var adjectives = 'res://english-nouns.txt'

func _ready():
	gen_random_mountain_name()
	
func gen_random_mountain_name():
	$"../course/name".set_text(load_file(adjectives) + "\n" + load_file(nouns))

func load_file(file):
	var line = ""
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		f.get_line()
		index += 1
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_line = rng.randi_range(0, index)
	index = 0
	f.seek(0)
	while not f.eof_reached():
		line = f.get_line()
		if index == random_line:
			break
		index += 1
	f.close()
	return line
