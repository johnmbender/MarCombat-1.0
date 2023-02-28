extends Node2D

var player1_name
var player1_node
var player1_wins

var player2_name
var player2_node
var player2_wins
var winner
var loser

var key_to_exit = false

var fight_speed = 1.1

var end_match = false
var end_game_input = false

var characters = ["John","Kelsie","Terje"]
var backgrounds = ["arrivals","breakRoom","humanHistory","lobby","naturalHistory","officeSpace","parking","roundhouse","shop"]
var fun_backgrounds = ["JapanRooftop","Japan_Bridge","JungleWater","Jungle","OldStreet"]
var background

var match_type
var game_controller
var storymode_controller
var continue_counter

func _ready():
	player1_wins = 0
	player2_wins = 0

func _input(event):
	if event is InputEventMouse:
		return
		
	if end_game_input:
		end_game_input = false
		reset()
		set_scene()
	elif not key_to_exit:
		return
	else:
		end_demo()
	

func reset():
	player1_wins = 0
	player2_wins = 0
	$HBoxContainer2/CountdownTimer.stop()
	$HBoxContainer2/Countdown.visible = false
	$UI/Player1/SkullContainer/Skull.visible = false
	$UI/Player2/SkullContainer/Skull.visible = false
	game_controller.fight_music_adjust("raise")

func end_demo():
	game_controller.destroy_demo_end_timer()
	game_controller.ambience_fade("out")
	player1_node.get_node("ActionTimer").stop()
	player1_node.action = null
	player1_node.fighting = false
	player1_node.victory()
	player2_node.get_node("ActionTimer").stop()
	player2_node.action = null
	player2_node.fighting = false
	player2_node.victory()
	$AnimationPlayer.play("end match fade")

func set_game_controller(controller):
	game_controller = controller

func set_storymode_controller(controller):
	storymode_controller = controller

func set_player1(playerName:String):
	player1_name = playerName

func set_player2(playerName:String):
	player2_name = playerName

func set_match_type(type:String):
	match_type = type

func set_background(bkg:String):
	background = bkg
	if game_controller.ambience_playing() == false:
		set_background_sounds(bkg)

func set_background_sounds(location:String):
	match location:
		"arrivals","courtyard","lobby","roundhouse","shop":
			game_controller.play_ambience("public_loud")
		"humanHistory","naturalHistory":
			game_controller.play_ambience("public_quiet")
		"breakRoom","hallway","parking":
			game_controller.play_ambience("office_drone")
		"rooftop":
			game_controller.play_ambience("rooftop")
		"officeSpace":
			game_controller.play_ambience("pete")

func addPlayer(character:String, node_name:String, bot:bool):
	var scenePath = "res://characters/%s/%s.tscn" % [character, character]
	var player = load(scenePath).instance()
	player.name = node_name
	if bot:
		player.script = load("res://scripts/AI.gd")
	
	player.set_bot(bot)
	player.character_name = character
	player.set_game_controller(game_controller)
	add_child(player)
	player.health = 100
	player.idle()

	if node_name == "player1":
		player.facing = "right"
		$UI/Player1/HBoxContainer/Name.text = player1_name
		if player1_wins == 1:
			$UI/Player1/SkullContainer/Skull.visible = true
		$UI/Player1/HealthBar.value = 100
	
		player.position = Vector2(100, 350)
		player.collision_layer = 1
		player.collision_mask = 48
		player.get_node("AttackCircle").collision_layer = 2
	elif node_name == "player2":
		player.facing = "left"
		if $player2.character_name == $player1.character_name:
			if match_type == "storymode":
				$UI/Player2/HBoxContainer/Name.text = "%s's self-doubt" % player2_name
			else:
				$UI/Player2/HBoxContainer/Name.text = "Nega %s" % player2_name
			
			$player2.modulate = Color(0.6, 0.6, 0.6, 0.8)
			$player2.get_node("NegaSmoke").playing = true
			$player2.get_node("NegaSmoke").visible = true
		else:
			$UI/Player2/HBoxContainer/Name.text = player2_name
		
		$UI/Player2/HealthBar.value = 100
		
		if player2_wins == 1:
			$UI/Player2/SkullContainer/Skull.visible = true
		
		player.position = Vector2(924, 350)
		player.collision_layer = 16
		player.collision_mask = 3
		player.get_node("AttackCircle").collision_layer = 32
	
	return player

func set_scene():
	if match_type == null:
		match_type = "demo"
	if player1_name == null:
		randomize()
		set_player1(characters[randi() % characters.size()])
		#ai vs ai demo key to quit
		key_to_exit = true
	if player2_name == null:
		if match_type == "demo":
			# remove player1 from list of characters so there's no NegaFighter
			characters.erase(player1_name)
		
		randomize()
		set_player2(characters[randi() % characters.size()])
	if background == null:
		randomize()
		if randf() <= 0.5:
			set_background(backgrounds[randi() % backgrounds.size()-1])
			$Background.texture = load("res://levels/backgrounds/%s.jpg" % background)
			$Background.visible = true
		else:
			load_fun_background(fun_backgrounds[randi() % fun_backgrounds.size()-1])
	else:
		$Background.texture = load("res://levels/backgrounds/%s.jpg" % background)
		$Background.visible = true
	
	if player1_node:
		remove_child(player1_node)
		player1_node.queue_free()
		remove_child(player2_node)
		player2_node.queue_free()
	
	match match_type:
		"demo":
			player1_node = addPlayer(player1_name, "player1", true)
			player2_node = addPlayer(player2_name, "player2", true)
			$AnimationPlayer.play("press key to start flash")
		"storymode","deathmatch":
			player1_node = addPlayer(player1_name, "player1", false)
			player2_node = addPlayer(player2_name, "player2", true)
		"multiplayer":
			pass
	
	player1_node.enemy = player2_node
	player2_node.enemy = player1_node
	player1_node.will_collapse = false
	player2_node.will_collapse = false
	
	if match_type != "demo":
		format_text_for_label("Round %s" % (player1_wins + player2_wins + 1))
		$AnimationPlayer.play("intro")
	else:
		$UI.visible = false
		player1_node.fighting = true
		player1_node.doSomething()
		player2_node.fighting = true
		player2_node.doSomething()

func load_fun_background(bkg:String):
	if bkg == "JapanRooftop" or bkg == "OldStreet":
		$Background.texture = load("res://levels/backgrounds/fun/%s.jpg" % background)
		$Background.visible = true
	else:
		$Background.visible = false
		$AnimatedBackground.play(bkg)

func update_health(player, health:int):
	if match_type == "demo":
		player1_node.health = 100
		player2_node.health = 100
		return
	
	if player.health <= 0:
		player.health = 0
		
	if player == player1_node:
		$UI/Player1/HealthBar.value = health
	else:
		$UI/Player2/HealthBar.value = health
	
	if player.health > 0:
		return
	
	# other play won fight
	if player == player1_node:
		player2_wins += 1
	else:
		player1_wins += 1
	
	if player1_wins == 2:
		winner = player1_node
		loser = player2_node
		player2_node.stunned()
		player2_node.fighting = false
		player1_node.can_use_fatality = true
		$FatalityTimer.start()
	elif player2_wins == 2:
		if match_type == "storymode":
			player1_node.fighting = false
			if not player1_node.will_collapse:
				player1_node.collapse()
				
			player2_node.fighting = false
			player2_node.victory()
			if player1_name == player2_name:
				announcer_speak("self-defeat")
			else:
				announcer_speak(player.enemy.character_name)
			$EndFightTimer.wait_time = 3
			$EndFightTimer.start()
		else:
			winner = player2_node
			loser = player1_node
			player1_node.stunned()
			player1_node.fighting = false
			player2_node.can_use_fatality = true
			$FatalityTimer.start()
	else:
		# undeciding round
		player.blocking = false
		player.attacking = false
		player.crouching = false
		player.fighting = false
#		player.get_node("AnimationPlayer").play("idle")
		if player.will_collapse == false:
			player.collapse()
		player.enemy.fighting = false
		announcer_speak(player.enemy.character_name)
		var smoke = player.get_node("NegaSmoke")
		smoke.visible = false
		smoke.playing = false
		$EndFightTimer.wait_time = 3
		$EndFightTimer.start()

func _on_EndFightTimer_timeout():
	if match_type != "storymode":
		if player1_wins >= 2 or player2_wins >= 2:
			$AnimationPlayer.play("end match fade")
			game_controller.ambience_fade("out")
		else:
			$AnimationPlayer.play("fade to round")
	elif match_type == "storymode":
		if player1_wins >= 2:
			$AnimationPlayer.play("end match fade")
			game_controller.ambience_fade("out")
		elif player2_wins >=2:
			format_text_for_label("continue?")
			continue_counter = 10
			move_child($HBoxContainer2, get_child_count())
			$HBoxContainer.visible = true
			$HBoxContainer2/Countdown.visible = true
			$HBoxContainer2/CountdownTimer.start()
			announcer_speak("continue")
			end_game_input = true
		else:
			$AnimationPlayer.play("fade to round")

func match_over(w):
	$FatalityTimer.stop()
	winner = w
	loser = winner.enemy
	winner.victory()
	format_text_for_label("%s wins" % winner.character_name)
	announcer_speak(winner.character_name)
	$EndFightTimer.start()

func format_text_for_label(text:String):
	var width = text.length() * 59
	$HBoxContainer/Words.rect_min_size.x = width
	$HBoxContainer/Words.rect_position.x = (1024 - width) / 2
	$HBoxContainer/Words.text = text.to_upper()
	$HBoxContainer/Words.visible = true

func announcer_speak(line:String):
	var path = "res://sounds/announcer/"
	if line == "round":
		var round_number = player1_wins + player2_wins + 1
		$Announcer.stream = load("%sround%s.wav" % [path, round_number])
	else:
		$Announcer.stream = load("%s%s.wav" % [path, line])
		
	$Announcer.playing = true

func fatality_modulate(which:String):
	$AnimationPlayer.play("fatality modulate %s" % which)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			player1_node.fighting = true
			if player1_node.bot:
				player1_node.doSomething()
			player2_node.fighting = true
			if player2_node.bot:
				player2_node.doSomething()
		"end match fade":
			if match_type == "storymode":
				storymode_controller.fight_done()
			else:
				game_controller.fight_done()

func _on_FatalityTimer_timeout():
	loser.collapse()
	winner.victory()
	$EndFightTimer.start()


func _on_CountdownTimer_timeout():
	continue_counter -= 1
	
	if continue_counter <= -1:
		$HBoxContainer2/CountdownTimer.stop()
		game_controller.fight_music_fade("out")
		game_controller.ambience_fade("out")
		game_controller.storymode_quit()
	else:
		$HBoxContainer2/Countdown.text = "%s" % continue_counter
