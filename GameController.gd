extends Node2D

var current_scene
var game_mode
var intro_shown = false

func _ready():
	load_launch_screen()

func load_launch_screen():
	var scene = preload("res://scenes/LaunchScreen.tscn").instance()
	scene.set_game_controller(self)
	add_child(scene)
	
	if current_scene != "LaunchScreen":
		remove_scene()
	current_scene = "LaunchScreen"

func load_character_select():
	var scene = preload("res://scenes/CharacterSelect.tscn").instance()
	scene.set_game_controller(self)
	add_child(scene)
	remove_scene()
	current_scene = "CharacterSelect"

func load_mode(player1, player2):
	match game_mode:
		"deathmatch":
			load_deathmatch(player1, player2)
		"storymode":
			load_storymode(player1)

func load_storymode(player):
	var scene = preload("res://scenes/StoryModeController.tscn").instance()
	add_child(scene)
	remove_scene()
	current_scene = "StoryModeController"
	scene.set_player(player)
	scene.set_game_controller(self)
	scene.prepare_story()
	$AnimationPlayer.play("fade to storymode")

func load_deathmatch(player1, player2):
	var characters = ["John","Kelsie","Terje"]
	randomize()
	characters.shuffle()
	if player2 == false:
		# vs AI opponent
		var scene = preload("res://scenes/FightScene.tscn").instance()
		scene.set_game_controller(self)
		add_child(scene)
		remove_scene()
		current_scene = "FightScene"
		scene.set_player1(player1)
		scene.set_player2(characters[0])
		scene.set_match_type("deathmatch")
		scene.set_scene()
		raise_fight_music()
	else:
		# 2 players
		pass

func load_demo():
	raise_fight_music()
	current_scene = "FightScene"
	var scene = preload("res://scenes/FightScene.tscn").instance()
	add_child(scene)
	scene.set_game_controller(self)
	scene.set_scene()

func raise_fight_music(transition:bool = true):
	if transition:
		$AnimationPlayer.play("fight music")
	else:
		$AnimationPlayer.play("just fight music")

func lower_fight_music():
	$AnimationPlayer.play("intro music")

func storymode_to_fight_scene():
	$AnimationPlayer.play("storymode to fight scene")

func fight_to_conversation():
	$AnimationPlayer.play("fight to conversation")

func scene_ready(scene:String):
	match scene:
		"LaunchScreen":
			$LaunchScreen.start(intro_shown)

func flag_intro_shown():
	intro_shown = true

func set_game_mode(mode:String):
	game_mode = mode
	var removable = get_node(current_scene)
	remove_child(removable)
	removable.queue_free()
	
	match game_mode:
		"storymode":
			load_character_select()
		"deathmatch":
			load_character_select()
		"multiplayer":
			pass
		"ai_vs_ai":
			load_demo()

func fight_done():
	remove_scene()
	$AnimationPlayer.play("fade fight music")
	match game_mode:
		"deathmatch","ai_vs_ai":
			load_launch_screen()
#		"storymode":
#			print("next storymode scene!")

func storymode_quit():
	remove_scene()
	load_launch_screen()
	$IntroMusic.playing = true

func gong():
	$Gong.play()

func fatalityHorn():
	$FatalityHorn.play()
	fade_fight_music()

func fade_fight_music(transition:bool = true):
	if transition:
		$AnimationPlayer.play("fade fight music")
	else:
		$AnimationPlayer.play("just fade fight music")

func fade_conversation_music():
	$AnimationPlayer.play("fade conversation music")

func quit_game():
	$AnimationPlayer.play("quit")

func remove_scene():
	if current_scene:
		var node = get_node_or_null(current_scene)
		if node:
			remove_child(node)
			node.queue_free()
	current_scene = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "quit":
		get_tree().quit()
