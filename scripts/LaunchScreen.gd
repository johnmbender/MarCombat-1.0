extends Node2D

var allow_input
var next_screen
var selection = 0
var selections = [[Vector2(330, 300), Vector2(690, 300)], [Vector2(290, 370), Vector2(730, 370)], [Vector2(390, 430), Vector2(630, 430)]]

func _ready():
	allow_input = false
	start()

func start():
	$AnimationPlayer.play("fadeIn")
	next_screen = preload("res://scenes/CharacterSelectScreen.tscn").instance()
	
func _input(event):
	if allow_input == false:
		return

	if event.is_action_pressed("ui_accept"):
		do_selection()
	elif event.is_action_released("ui_down"):
		move_skulls(1)
	elif event.is_action_released("ui_up"):
		move_skulls(-1)
	elif event.is_action_released("quit"):
		get_tree().quit()

func allow_input():
	allow_input = true

func move_skulls(direction:int):
	selection = selection + direction
	if selection == selections.size():
		selection = 0
	elif selection < 0:
		selection = selections.size()-1
	
	$MammothLeft.position = selections[selection][0]
	$MammothRight.position = selections[selection][1]

func do_selection():
	match selection:
		0:
			load_game()
		1:
			return
		2:
			get_tree().quit()

func load_game():
	$Boom.play()
	$AnimationPlayer.play("fadeOut")

func go_to_character_select():
	allow_input = false
	get_tree().get_root().add_child(next_screen)
	next_screen.enabled = true

func fadeLevelAmbience():
	get_tree().get_root().get_node("Environment/AnimationPlayer").play("fadeAmbience")

func _on_Music_finished():
	$IntroMusic.play()
	# start demo
	# this doesn't work
#	var random = RandomNumberGenerator.new()
#	random.randomize()
#	var players = ['John', 'Kelsie', 'Terje']
#	var levelScene = preload("res://levels/WestEntrance.tscn")
#	var rand_char1 = players[random.randi_range(0,2)]
#	var rand_char2 = players[random.randi_range(0,2)]
#	var level = levelScene.instance()
#	level.selected_player1 = rand_char1
#	level.selected_player2 = rand_char2
#	level.demoMode = true
#	get_tree().change_scene_to(levelScene)
