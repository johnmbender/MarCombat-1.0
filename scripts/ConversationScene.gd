extends Node2D

var fight_number
var scene_script
var exposition

var player
var player_pronouns
var player_script

var opponent
var opponent_pronouns
var opponent_script

var background

var sound_effect
var current_line

var game_controller
var storymode_controller

var speaker
var next_action = null
onready var ignore_keypress = false # stores if the user's keypresses will be ignored or not
onready var first_line_spoken = false # start convo automatically

func set_game_controller(controller):
	game_controller = controller

func set_storymode_controller(controller):
	storymode_controller = controller

func set_fight_number(fight:int):
	fight_number = fight

func set_player(playerName:String):
	player = playerName
	load_actor_scene(player, "player")

func set_opponent(playerName:String):
	opponent = playerName
	load_actor_scene(opponent, "opponent")

func load_actor_scene(character:String, role:String):
	var scene = load("res://characters/%s/%s-conversation.tscn" % [character, character]).instance()
	get_node("ContentContainer/%s" % role).add_child(scene)
	if role == "player":
		player_script = load_script("player")
		var position = Vector2(-200, 50)
		if character == "Terje":
			position.y = 100
				
		scene.global_position = position
	else:
		scene.flip_h = true
		opponent_script = load_script("opponent")
		var position = Vector2(400, 50)
		if character == "Terje":
			position.y = 100
		elif character == "Ox_Anna":
			position = Vector2(440, 120)
		elif character == "FUGUM":
			scene.scale = Vector2(1.2, 1.2)
			position = Vector2(400, 100)
			scene.set_controller(self)

		scene.global_position = position

func load_script(role:String):
	var node = get_node("ContentContainer/%s/AnimatedSprite" % role)
	var dialogue = node.get_dialogue(role, fight_number)
	if role == "player":
		player_pronouns = node.get_pronouns()
	else:
		opponent_pronouns = node.get_pronouns()
		
	return dialogue

func set_background(bkg:String):
	$ContentContainer/Background.texture = load("res://levels/backgrounds/%s.jpg" % bkg)
	set_background_sounds(bkg)

func set_background_sounds(location:String):
	match location:
		"arrivals","courtyard","lobby","roundhouse","shop":
			game_controller.play_ambience("public_loud")
		"humanHistory","naturalHistory":
			game_controller.play_ambience("public_quiet")
		"breakroom","hallway","parking":
			game_controller.play_ambience("office_drone")
		"office":
			game_controller.play_ambience("pete")
		"rooftop":
			game_controller.play_ambience("rooftop")

func start_conversation():
	current_line = 0
	scene_script = Array()
	
	set_exposition()
	merge_scripts()
	
	match fight_number:
		1, 2, 3, 4:
			$ContentContainer/opponent.modulate = Color(1,1,1,0)

	speak_line()

func set_exposition():
	exposition = {
		0: {
			0: {
				"line": "The year is 2019. The new museum opened nearly two years ago to great fanfare, followed by a hugely successful feature exhibit.\n\nOptimism was high, and COVID-19 was completely unheard of.\n\nOne day, %s comes up with the best idea ever.\n\n%s idea would skyrocket the prestige of the museum, make it highly profitable, and spike morale. It's risk-free and nearly zero cost.\n\n%s wants to run the idea past a coworker before taking it up the line.\n\n%s finds %s and explains it to %s, who cheerfully provides constructive feedback..." % [player, player_pronouns[2], player_pronouns[0], player, opponent, opponent_pronouns[1]],
			}
		},
		1: {
			5: {
				"line": "%s explains %s brilliant idea to %s, what just happened, and cautiously watches %s's response." % [player, player_pronouns[2], opponent, opponent]
			}
		},
		4: {
			4: {
				"line": "%s goes to Starbucks and gets Oksana's favourite: Americano, black.\n\nWhen %s returns, %s finds Oksana upstairs on the patio." % [player, player_pronouns[0], player_pronouns[0]]
			}
		},
		5: {
			4: {
				"line": "%s goes to %s desk and types a well-thought out and comprehensive explanation of %s idea, complete with tangible milestones, goals, and deliverables.\n\nAfter an hour and a half, %s is ready to hit send..." % [player, player_pronouns[2], player_pronouns[2], player]
			},
			8: {
				"line": "Three hours and an entire rewrite later ..."
			},
			18: {
				"line": "%s hops on the LRT to Government Centre." % player
			}
		}
	}

func merge_scripts():
	var lines = player_script.size() + opponent_script.size() + exposition.size()
	
	# if it's the fight before player loses their cool on a coworker,
	# spice up the dialogue a bit
	if fight_number == 1: # second fight; third fight we're just angry
		if player == "John":
			match opponent:
				"Kelsie":
					player_script[9]['line'] = 'Tell me, %s... how do you pronounce "gif"?' % opponent
					opponent_script[10]['line'] = ".... gif."
				"Terje":
					pass
				"Tyler":
					player_script[9]['line'] = 'You really bug me, %s.' % opponent
					opponent_script[10]['line'] = "Thinking that one up all day, were ya?"
		elif player == "Kelsie":
			match opponent:
				"John":
					player_script[9]['line'] = 'Tell me, %s... how do you pronounce "gif"?' % opponent
					opponent_script[10]['line'] = ".... gif."
				"Terje":
					pass
				"Tyler":
					pass
		elif player == "Terje":
			match opponent:
				"John":
					pass
				"Kelsie":
					player_script[9]['line'] = "Tell me, %s... are you still leeching off your sister's Peloton account? Mooch."
					opponent_script[10]["line"] = "You son of a bitch."
				"Tyler":
					pass
		elif player == "Tyler":
			match opponent:
				"John":
					player_script[9]['line'] = "This game sucks."
					opponent_script[10]["line"] = "You son of a bitch."
				"Kelsie":
					pass
				"Terje":
					pass
	
	for n in range(0, lines):
		if exposition.has(fight_number) and exposition[fight_number].has(n):
			exposition[fight_number][n]["role"] = 'exposition'
			scene_script.append(exposition[fight_number][n])
		if player_script.has(n):
			player_script[n]['role'] = "player"
			scene_script.append(player_script[n])
		if opponent_script.has(n): #elif, if this suddenly doesn't work?!
			opponent_script[n]['role'] = "opponent"
			scene_script.append(opponent_script[n])

func _input(event):
	if ignore_keypress or event is InputEventMouse:
		return # so dumb
	
	# to skip chat straight to fight
#	if event.is_action_pressed("cheat"):
#		current_line = scene_script.size()
	
	# resart keypress timer
	ignore_keypress = true
	var FUGUM_voice = get_node_or_null("ContentContainer/opponent/AnimatedSprite/Voice")
	if FUGUM_voice:
		FUGUM_voice.stop()
	$Announcer.stop()
	$KeypressTimer.start()
		
	if $AnimationPlayer.is_playing() and ["speak","play exposition"].has($AnimationPlayer.current_animation) and $AnimationPlayer.playback_speed < 5:
		$AnimationPlayer.advance(100)
	elif next_action:
		match next_action:
			"speak_line":
				speak_line()
			"exposition to dialogue":
				$AnimationPlayer.playback_speed = 1
				$AnimationPlayer.play("exposition to dialogue")
			"dialogue to exposition":
				$AnimationPlayer.playback_speed = 1
				$AnimationPlayer.play("dialogue to exposition")
				
		next_action = null
	
func speak_line():
	if current_line >= scene_script.size():
		if opponent == "FUGUM":
			$VS.text = "VS"
			$ContentContainer/opponent/AnimatedSprite.modulate = Color(0,0,0,1)
			$ContentContainer/opponent.scale = Vector2(1.5, 1.5)
			$ContentContainer/opponent.position = Vector2(0, 0)
			$ContentContainer/opponent/AnimatedSprite.play("fight")
		else:
			game_controller.play_fight_music()
			
		$AnimationPlayer.play("vs")
		return
		
	var line = scene_script[current_line]
	var role = line["role"]

	if role == "exposition":
		if current_line == 0:
			$Exposition.text = line["line"]
			set_speaking_speed(line["line"])
			$AnimationPlayer.play("play exposition")
		else:
			$Exposition.text = line["line"]
			$ContentContainer/DialogueBox/Dialogue.percent_visible = 0
			$AnimationPlayer.play("dialogue to exposition")
			if current_line == 18:
				game_controller.storymode_music_fade("out")
				game_controller.ledge_music()
		current_line += 1
	else:
		if current_line == 0 && $ContentContainer.modulate == Color(0,0,0,1):
			$AnimationPlayer.play("fade to dialogue")
		else:
			var action = line["action"]
			var text = line["line"]
			
			if opponent == "FUGUM" and player == "John":
				if role == "player":
					if current_line == 5:
						current_line = 9
						text = "Sent!"
				elif action == "normal" or action == "message":
					action = "%s-mac" % action
			
			get_node("ContentContainer/%s/AnimatedSprite" % role).play(action)
			
			if opponent == "Ox_Anna":
				if current_line == 8:
					$CoffeeRevealer.play("reveal")
				elif current_line == 10:
					$CoffeeRevealer.play("hide")
				elif current_line == 11:
					$AnimationPlayer.play("vs")

			if text != null:
				if "%s" in text:
					if role == "player":
						text = text % opponent
					else:
						text = text % player
						
				$ContentContainer/DialogueBox/Dialogue.text = text
				set_speaking_speed(text)
				if opponent == "FUGUM":
					if role == "player":
						$ContentContainer/DialogueBox/Dialogue.modulate = Color(1,1,1,1)
					else:
						if current_line == 44 or current_line == 46:
							# Announcer red
							$ContentContainer/DialogueBox/Dialogue.modulate = Color(1,0,0,1)
						else:
							# Alberta Blue would be better, but can't read it
							$ContentContainer/DialogueBox/Dialogue.modulate = Color(1,1,0,1)
				speaker = role
				light_actor()
				$AnimationPlayer.play("speak")
				
				if opponent == "FUGUM":
					match current_line:
						20,22,24,26,28,30,32,34,36,38,40,42,47:
							ignore_keypress = true
							if current_line != 30:
								$ContentContainer/opponent/AnimatedSprite/Voice.stream = load("res://sounds/characters/FUGUM/%s.ogg" % current_line)
							else:
								$ContentContainer/opponent/AnimatedSprite/Voice.stream = load("res://sounds/characters/FUGUM/%s-%s.ogg" % [current_line, player])
							$ContentContainer/opponent/AnimatedSprite/Voice.play()
						44:
							ignore_keypress = true
							$Announcer.stream = load("res://sounds/announcer/fugum_01.ogg")
							$Announcer.play()
						46:
							ignore_keypress = true
							$Announcer.stream = load("res://sounds/announcer/fugum_02.ogg")
							$Announcer.play()
					
				current_line += 1
			else:
				# skips lines with no dialogue, such as FUGUM whilst a monitor
				current_line += 1
				speak_line()
			
			if action == "fight":
				get_node("ContentContainer/%s" % role).modulate = Color(1,1,1,1)
				current_line += 1
				speak_line()

func set_speaking_speed(text:String):	
	var chars = text.length()
	if chars == 0:
		return
	
	var chars_per_sec = 25
	var seconds = float(chars) / chars_per_sec
	seconds = clamp(seconds, 0.5, seconds)
	var speed = 1.0 / seconds

	$AnimationPlayer.playback_speed = speed

func light_actor():
	if opponent == player and current_line < 4:
		# slowly fade in self-doubt each line player speaks
		$ContentContainer/opponent.modulate.a = clamp(current_line - 1, 0, 3) * 0.23
		$ContentContainer/player.modulate = Color(1,1,1,1)
	elif (fight_number == 1 and current_line < 2) or (fight_number == 2 and current_line < 1):
		# delay opponent for one line in fight #2 and #3 (1)
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate.a = 0.0
	elif opponent == "Ox_Anna" and current_line < 5:
		# Oksana shows up at line 5
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate.a = 0.0
	elif opponent == "FUGUM":
		if current_line < 5:
			$ContentContainer/player.modulate = Color(1,1,1,1)
			$ContentContainer/opponent.modulate = Color(1,1,1,0)
	elif speaker == "player":
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate = Color(0.55, 0.55, 0.55, 1)
	elif speaker == "opponent":
		$ContentContainer/opponent.modulate = Color(1,1,1,1)
		$ContentContainer/player.modulate = Color(0.55, 0.55, 0.55, 1)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"play exposition": # exposition is finished playing
			if opponent == "Ox_Anna":
				# change background to rooftop
				set_background("rooftop")
			elif opponent == "FUGUM":
				if current_line == 5:
					set_background('officeSpace-blurred')
					game_controller.play_ambience("office_drone")
					$ContentContainer/opponent.modulate = Color(1,1,1,1)
				elif current_line == 19:
					set_background('legislature-convo')
					$ContentContainer/opponent/AnimatedSprite.play("hidden")
			next_action = "exposition to dialogue"
			if opponent == "FUGUM" and player == "John" and current_line == 5:
				$ContentContainer/opponent/AnimatedSprite.play("normal-mac")
		"exposition to dialogue":
			$Exposition.text = ""
			next_action = "speak_line"
			speak_line()
		"dialogue to exposition":
			if opponent == "FUGUM" and player != "John" and current_line == 8:
				speak_line()
				
			$AnimationPlayer.play("play exposition")
			$ContentContainer/player/AnimatedSprite.play("normal")
			$ContentContainer/opponent/AnimatedSprite.play("normal")
			if opponent == "Ox_Anna":
				$ContentContainer/opponent.modulate = Color(0.55, 0.55, 0.55, 1)
		"fade to dialogue":
			next_action = "speak_line"
			speak_line()
		"speak":
			if opponent == "FUGUM" and player != "John" and current_line == 8:
#				current_line += 1
				$AnimationPlayer.play("dialogue to exposition")
			else:
				next_action = "speak_line"
		"vs":
			storymode_controller.conversation_done()


func _on_KeypressTimer_timeout():
	ignore_keypress = false

func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"speak":
			pass
#			ignore_keypress = false
		"play exposition":
#			ignore_keypress = false
			$ContentContainer/DialogueBox/Dialogue.percent_visible = 0

func _on_Announcer_finished():
	ignore_keypress = false

func voice_finished():
	ignore_keypress = false
