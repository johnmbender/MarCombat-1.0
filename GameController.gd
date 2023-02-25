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
	storymode_music_fade("in")
	intro_music_fade("out")

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
		fight_music_fade("in")
		intro_music_fade("out")
	else:
		# 2 players
		pass

func load_demo():
	fight_music_fade("in")
	intro_music_fade("out")
	current_scene = "FightScene"
	var scene = preload("res://scenes/FightScene.tscn").instance()
	add_child(scene)
	scene.set_game_controller(self)
	scene.set_scene()


func scene_ready(scene:String):
	match scene:
		"LaunchScreen":
			$LaunchScreen.start(intro_shown)
			$IntroMusic.volume_db = 0
			$IntroMusic.play()

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
	if $FightMusic.is_playing():
		fight_music_fade("out")

	intro_music_fade("in")
	match game_mode:
		"deathmatch","ai_vs_ai":
			load_launch_screen()
#		"storymode":
#			print("next storymode scene!")

func storymode_quit():
	remove_scene()
	load_launch_screen()
	intro_music_fade("in")

func gong():
	$Gong.play()

func fatalityHorn():
	$FatalityHorn.play()
	fight_music_fade("out")

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

# MUSIC CONTROLLERS
func intro_music_fade(which:String, speed:float = 1.0):
	$IntroMusic/IntroPlayer.playback_speed = speed
	$IntroMusic/IntroPlayer.play("fade %s" %which)

func intro_music_adjust(which:String, speed:float = 1.0):
	$IntroMusic/IntroPlayer.playback_speed = speed
	$IntroMusic/IntroPlayer.play(which)

func storymode_music_fade(which:String, speed:float = 1.0):
	$StoryModeMusic/StoryModePlayer.playback_speed = speed
	$StoryModeMusic/StoryModePlayer.play("fade %s" %which)

func storymode_music_adjust(which:String, speed:float = 1.0):
	$StoryModeMusic/StoryModePlayer.playback_speed = speed
	$StoryModeMusic/StoryModePlayer.play(which)

func fight_music_fade(which:String, speed:float = 1.0):
	$FightMusic/FightPlayer.playback_speed = speed
	$FightMusic/FightPlayer.play("fade %s" %which)

func fight_music_adjust(which:String, speed:float = 1.0):
	$FightMusic/FightPlayer.playback_speed = speed
	$FightMusic/FightPlayer.play(which)

func _on_IntroPlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		$IntroMusic.playing = false


func _on_IntroPlayer_animation_started(anim_name):
	if anim_name == "fade in":
		$IntroMusic.playing = true


func _on_StoryModePlayer_animation_started(anim_name):
	if anim_name == "fade in":
		$StoryModeMusic.playing = true


func _on_StoryModePlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		$StoryModeMusic.playing = false

func _on_FightPlayer_animation_started(anim_name):
	if anim_name == "fade in":
		$FightMusic.playing = true

func _on_FightPlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		$FightMusic.playing = false

