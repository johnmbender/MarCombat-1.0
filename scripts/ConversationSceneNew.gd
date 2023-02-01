extends Node2D

var scene_number

var player
var player_script

var opponent
var opponent_script

var scene_script

func _ready():
	# REMOVE LATER:
	# these will be set by StoryModeController
	set_scene(0)
	set_player("Kelsie")
	set_opponent("Terje")
	# END REMOVE LATER
	
	merge_scripts()
	print(scene_script)

func set_scene(scene:int):
	scene_number = scene

func set_player(playerName:String):
	player = playerName
	player_script = load_script(player, 'player')
#	load_scene(player, "player")

func set_opponent(playerName:String):
	opponent = playerName
	opponent_script = load_script(opponent, 'opponent')
#	load_scene(opponent, "opponent")

func load_script(character:String, role:String):
	var script = load("res://scripts/storymode/%s.gd" % character).new()
	var dialogue = script.dialogue[role]['scene'][scene_number]
	return dialogue
	

func load_scene(character:String, role:String):
	var scene = load("res://characters/%s/%s-conversation.tscn" % [character, character]).instance()
	scene.name = role
	add_child(scene)

func merge_scripts():
	
	pass
