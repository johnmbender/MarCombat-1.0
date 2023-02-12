extends Node2D

var current_scene
var game_mode

func _ready():
	load_launch_screen()

func load_launch_screen():
	current_scene = "LaunchScreen"
	var scene = preload("res://scenes/LaunchScreen.tscn").instance()
	add_child(scene)

func load_deathmatch():
	raise_fight_music()
	current_scene = "FightScene"
	var scene = preload("res://scenes/FightScene.tscn").instance()
	add_child(scene)
	scene.set_selected_player1("John")
	scene.match_type = "deathmatch"
	scene.prepare_fight()

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
			load_deathmatch()
		"multiplayer":
			pass
		"ai_vs_ai":
			load_demo()

func fight_done():
	remove_scene()
	match game_mode:
		"deathmatch":
			load_launch_screen()
		"storymode":
			print("next storymode scene!")

func quit_game():
	$AnimationPlayer.play("quit")

func remove_scene():
	remove_child(get_node(current_scene))
	current_scene = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "quit":
		get_tree().quit()
