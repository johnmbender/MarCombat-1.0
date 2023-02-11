extends Node2D

var player1
var player2
var ready_players = 0

func _ready():
	set_scene()

func set_scene():
	var player1_scene = load("res://characters/John/John.tscn")
	player1 = player1_scene.instance()
	player1.script = load("res://scripts/AI-new.gd")
	add_child(player1)
	player1.idle()
	player1.set_name("John")
	player1.name = "player1"
	player1.set_bot(true)
	player1.position = Vector2(512, 200)
	player1.collision_layer = 1
	player1.collision_mask = 48
	player1.get_node("AttackCircle").collision_layer = 2
	
	#REMOVE LATER
	var player2_scene = load("res://characters/John/John.tscn")
	player2 = player2_scene.instance()
	player2.script = load("res://scripts/AI-new.gd")
	add_child(player2)
	player2.idle()
	player2.set_name("John")
	player2.name = "player2"
	player2.set_bot(true)
	player2.position = Vector2(650, 200)
	player2.collision_layer = 16
	player2.collision_mask = 3
	player2.get_node("AttackCircle").collision_layer = 32
	
	player1.enemy = player2
	player2.set_enemy(player1)
