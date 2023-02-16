extends Node2D

var current_scene
var game_mode

func _ready():
	load_launch_screen()

func load_launch_screen():
	current_scene = "LaunchScreen"
	var scene = preload("res://scenes/LaunchScreen.tscn").instance()
	add_child(scene)

func load_character_select():
	var scene = preload("res://scenes/CharacterSelect.tscn").instance()
	add_child(scene)
	remove_scene()
	current_scene = "CharacterSelect"

func load_deathmatch(player1, player2):
	var characters = ["John","Kelsie","Terje"]
	randomize()
	characters.shuffle()
	if player2 == false:
		# vs AI opponent
		var scene = preload("res://scenes/FightScene.tscn").instance()
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
	scene.prepare_fight()

func raise_fight_music():
	$AnimationPlayer.play("fight music")

func lower_fight_music():
	$AnimationPlayer.play("intro music")

func scene_ready(scene:String):
	match scene:
		"LaunchScreen":
			$LaunchScreen.start()

func set_game_mode(mode:String):
	game_mode = mode
	remove_child(get_node(current_scene))
	match game_mode:
		"storymode":
			pass
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
		"deathmatch":
			load_launch_screen()
		"storymode":
			print("next storymode scene!")

func gong():
	$Gong.play()

func fatalityHorn():
	$FatalityHorn.play()
#	$FightMusic.volume_db = -30

func quit_game():
	$AnimationPlayer.play("quit")

func remove_scene():
	remove_child(get_node(current_scene))
	current_scene = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "quit":
		get_tree().quit()
