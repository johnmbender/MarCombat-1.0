extends Node2D

var current_scene
var game_mode
var intro_shown = false
var menu_options = ["Continue","Controls","Quit"]
var menu_selection = 0

func _ready():
	load_launch_screen()
	pause_mode = PAUSE_MODE_PROCESS

func _unhandled_key_input(event):
	# if we don't have a game mode, or it's a demo, ignore
	if game_mode == null or game_mode == "ai_vs_ai":
		return
		
	var fight_scene = get_node_or_null("FightScene")
	if fight_scene == null:
		var SM_fight_scene = get_node_or_null("StoryModeController/FightScene")	
		
		if SM_fight_scene == null:
			return
	elif fight_scene.match_type == "demo":
		return
	
	if event.is_action_pressed("quit"):
		pause_game()
	elif $PauseMenu.visible == false:
		return
		
	elif event.is_action_pressed("ui_down"):
		move_menu_selection(1)
	elif event.is_action_pressed("ui_up"):
		move_menu_selection(-1)
	elif event.is_action_pressed("ui_accept"):
		if $PauseMenu/ControlsView.visible:
			$PauseMenu/ControlsView.visible = false
		else:
			menu_action()
	
func pause_game():
	if get_tree().is_paused():
		get_tree().paused = false
		fight_music_adjust("raise")
		$PauseMenu.visible = false
	else:
		fight_music_adjust("lower")
		menu_selection = 0
		$PauseMenu/Continue.modulate = Color(1,0,0,1)
		get_tree().paused = true
		$PauseMenu.visible = true
		move_child($PauseMenu, get_children().size())

func move_menu_selection(move:int):
	menu_selection += move
	if menu_selection < 0:
		menu_selection = menu_options.size()-1
	elif menu_selection >= menu_options.size():
		menu_selection = 0
	
	for n in menu_options.size():
		if n == menu_selection:
			get_node("PauseMenu/%s" % menu_options[n]).modulate = Color(1, 0, 0, 1)
		else:
			get_node("PauseMenu/%s" % menu_options[n]).modulate = Color(1, 1, 1, 1)

func menu_action():
	match menu_selection:
		0:
			pause_game()
		1:
			$PauseMenu/ControlsView.visible = true
		2:
			get_tree().paused = false
			if game_mode == "storymode":
				fight_music_fade("out")
				ambience_fade("out")
				load_launch_screen()
			else:
				fight_done()

func load_launch_screen():
	var scene = load("res://scenes/LaunchScreen.tscn").instance()
	scene.set_game_controller(self)
	add_child(scene)
	
	if current_scene != "LaunchScreen":
		remove_scene()
	current_scene = "LaunchScreen"

func load_character_select():
	var scene = load("res://scenes/CharacterSelect.tscn").instance()
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
	var scene = load("res://scenes/StoryModeController.tscn").instance()
	add_child(scene)
	remove_scene()
	current_scene = "StoryModeController"
	scene.set_player(player)
	scene.set_game_controller(self)
	scene.prepare_story()
	storymode_music_fade("in")
	menu_music_fade("out")

func load_deathmatch(player1, player2):
	var characters = ["John","Kelsie","Terje","Tyler"]
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
		if fight_music_playing() == false:
			play_fight_music() # is this always done twice?
	else:
		# 2 players
		pass

func play_fight_music(song:String = ""):
	if menu_music_playing():
		menu_music_fade("out")
	elif storymode_music_playing():
		storymode_music_fade("out")
	
	if song.length() == 0:
		var random = RandomNumberGenerator.new()
		random.randomize()
		$FightMusic.stream = load("res://music/fight_0%s.ogg" % random.randi_range(1,5))
	else:
		$FightMusic.stream = load("res://music/%s" % song)
		
	fight_music_fade("in")

func play_storymode_music():
	if menu_music_playing():
		menu_music_fade("out")
	elif fight_music_playing():
		fight_music_fade("out")
		
	var random = RandomNumberGenerator.new()
	random.randomize()
	$StoryModeMusic.stream = load("res://music/storymode_0%s.ogg" % random.randi_range(1,4))
	storymode_music_fade("in")

func play_random_sound(location:String):
	match location:
		"arrivals","breakroom","courtyard","hallway","humanHistory","lobby","naturalHistory","office","parking","roundhouse","shop":
			# closing announcement for now, could add more later
			$RandomSound.stream = load("res://sounds/closingAnnouncement.ogg")
			match location:
				"arrivals","courtyard","lobby","parking","roundhouse","shop","breakroom","hallway","office":
					# extra reverb
					$RandomSound.set_bus("ReverbMedium")
				_:
					# low reverb
					$RandomSound.set_bus("ReverbLow")
			$RandomSound.play()

func load_demo():
	current_scene = "FightScene"
	var scene = preload("res://scenes/FightScene.tscn").instance()
	add_child(scene)
	scene.set_game_controller(self)
	scene.set_scene()

func scene_ready(scene:String):
	match scene:
		"LaunchScreen":
			$LaunchScreen.start(intro_shown)
			if not intro_shown or not menu_music_playing():
				$MenuMusic.volume_db = 0
				$MenuMusic.play()

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
			var demo_end_timer = Timer.new()
			demo_end_timer.name = "DemoEndTimer"
			demo_end_timer.wait_time = 30
			demo_end_timer.one_shot = true
			demo_end_timer.connect("timeout", self, "end_demo")
			add_child(demo_end_timer)
			$DemoEndTimer.start()
			load_demo()

func end_demo():
	$FightScene.end_game_input = false
	destroy_demo_end_timer()
	$FightScene.end_demo()

func destroy_demo_end_timer():
	if get_node_or_null("DemoEndTimer"):
		$DemoEndTimer.queue_free()

func fight_done():
	if $FightMusic.is_playing():
		fight_music_fade("out")
	if $Ambience.is_playing():
		ambience_fade("out")
	remove_scene()

	match game_mode:
		"deathmatch","ai_vs_ai":
			load_launch_screen()

func storymode_quit():
	remove_scene()
	load_launch_screen()
	menu_music_fade("in")

func gong():
	$Gong.play()

func fatalityHorn():
	$FatalityHorn.play()
	fight_music_fade("out")

func quit_game():
	$AnimationPlayer.play("quit")

func remove_scene():
	if $PauseMenu.visible:
		$PauseMenu.visible = false
		
	if current_scene:
		var node = get_node_or_null(current_scene)
		if node:
			remove_child(node)
			node.queue_free()
	current_scene = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "quit":
		get_tree().quit()

# MUSIC and AMBIENCE CONTROLLERS
func ledge_music():
	storymode_music_fade("out")
	ambience_fade("out")
	$FightMusic.stream = load("res://music/ledge.ogg")
	fight_music_fade("in")

func barbeque_music():
	$FightMusic.stream = load("res://music/barbeque.ogg")
	fight_music_fade("in")

func menu_music_fade(which:String, speed:float = 1.0):
	$MenuMusic/MenuPlayer.playback_speed = speed
	$MenuMusic/MenuPlayer.play("fade %s" % which)

func menu_music_adjust(which:String, speed:float = 1.0):
	$MenuMusic/MenuPlayer.playback_speed = speed
	$MenuMusic/MenuPlayer.play(which)

func menu_music_playing():
	return $MenuMusic.is_playing()

func storymode_music_fade(which:String, speed:float = 1.0):
	$StoryModeMusic/StoryModePlayer.playback_speed = speed
	$StoryModeMusic/StoryModePlayer.play("fade %s" % which)

func storymode_music_adjust(which:String, speed:float = 1.0):
	$StoryModeMusic/StoryModePlayer.playback_speed = speed
	$StoryModeMusic/StoryModePlayer.play(which)

func storymode_music_playing():
	return $StoryModeMusic.is_playing()

func fight_music_fade(which:String, speed:float = 1.0):
	$FightMusic/FightPlayer.playback_speed = speed
	$FightMusic/FightPlayer.play("fade %s" % which)

func fight_music_adjust(which:String, speed:float = 1.0):
	$FightMusic/FightPlayer.playback_speed = speed
	$FightMusic/FightPlayer.play(which)

func fight_music_playing():
	return $FightMusic.is_playing()

func ambience_fade(which:String):
	$Ambience/AmbiencePlayer.play("fade %s" % which)

func play_ambience(which:String):
	$Ambience.stream = load("res://sounds/ambience/%s.ogg" % which)
	if which == "pete":
		# randomize start point for Pete
		# this doesn't work because we set the time and then
		# the animation actually plays and starts, which sets it back at 0
		var start = rand_range(0.0, 90.0)
		$Ambience.seek(start)
	ambience_fade("in")

func stop_ambience():
	ambience_fade("out")

func ambience_playing():
	return $Ambience.is_playing()

func _on_MenuPlayer_animation_started(anim_name):
	if anim_name == "fade in":
		$MenuMusic.playing = true

func _on_MenuPlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		$MenuMusic.playing = false

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

func _on_AmbiencePlayer_animation_started(anim_name):
	if anim_name == "fade in":
		$Ambience.playing = true

func _on_AmbiencePlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		$Ambience.playing = false
