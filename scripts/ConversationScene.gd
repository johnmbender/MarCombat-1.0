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

var speaker
var next_action = null
onready var ignore_keypress = false # stores if the user's keypresses will be ignored or not
onready var first_line_spoken = false # start convo automatically

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
			sound_effect = load("res://sounds/publicSpace.mp3")
			$Ambience.volume_db = -10
		"humanHistory","naturalHistory":
			sound_effect = load("res://sounds/publicSpace.mp3")
			$Ambience.volume_db = -20
		"office":
			sound_effect = load("res://sounds/pete.mp3")
	
	$Ambience.stream = sound_effect

func start_conversation():
	current_line = 0
	scene_script = Array()
	
	set_exposition()
	merge_scripts()
	
	match fight_number:
		1, 2, 3:
			$ContentContainer/opponent.modulate = Color(1,1,1,0)
	
	speak_line()

func set_exposition():
	exposition = {
		0: {
			0: {
				"line": "One day, %s comes up with the best idea ever.\n\n%s idea would skyrocket the prestige of the museum, make it highly profitable, and spike morale. It's risk-free and nearly zero cost.\n\n%s wants to run the idea past a coworker before taking it up the line.\n\n%s finds %s and explains it to %s, who cheerfully provides a lot of constructive feedback..." % [player, player_pronouns[2], player_pronouns[0], player, opponent, opponent_pronouns[1]],
			}
		},
		1: {
			5: {
				"line": "%s explains %s brilliant idea to %s, what just happened, and cautiously watches %s's response." % [player, player_pronouns[2], opponent, opponent]
			}
		},
		3: {
			4: {
				"line": "%s goes to Starbucks and gets Oksana's favourite: Americano, black.\n\nWhen %s gets back, %s finds Oksana upstairs on the patio." % [player, player_pronouns[0], player_pronouns[0]]
			}
		}
	}

func merge_scripts():
	var lines = player_script.size() + opponent_script.size() + exposition.size()
	
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

func play_ambience():
	$Ambience.play()

func _input(event): # jovi
	if ignore_keypress or event is InputEventMouse:
		return # so dumb
	
	# resart keypress timer
	ignore_keypress = true
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
		$AnimationPlayer.play("vs")
		return
		
	var line = scene_script[current_line]
	var role = line["role"]

	if role == "exposition":
		if current_line == 0:
			$Exposition.text = line["line"]
			set_speaking_speed(line["line"])
			$AnimationPlayer.play("play exposition") # jovi
		else:
			$Exposition.text = line["line"]
			$ContentContainer/DialogueBox/Dialogue.percent_visible = 0
			$AnimationPlayer.play("dialogue to exposition")
		current_line += 1
	else:
		if current_line == 0 && $ContentContainer.modulate == Color(0,0,0,1):
			$AnimationPlayer.play("fade to dialogue")
		else:
			var action = line["action"]
			var text = line["line"]
			get_node("ContentContainer/%s/AnimatedSprite" % role).play(action)
			
			if opponent == "Ox_Anna":
				if current_line == 8:
					$CoffeeRevealer.play("reveal")
				elif current_line == 10:
					$CoffeeRevealer.play("hide")
				elif current_line == 11:
					$AnimationPlayer.play("vs")

			if text != null:
				if "%" in text:
					if role == "player":
						text = text % opponent
					else:
						text = text % player
				$ContentContainer/DialogueBox/Dialogue.text = text
				set_speaking_speed(text)
				speaker = role
				light_actor()
				$AnimationPlayer.play("speak")
				current_line += 1
			
			if action == "fight":
				get_node("ContentContainer/%s" % role).modulate = Color(1,1,1,1)
				current_line += 1
				speak_line()

func set_speaking_speed(text:String):
	var chars = text.length()
	if chars == 0:
		return
	
	var chars_per_sec = 40
	var seconds = float(chars) / chars_per_sec
	seconds = clamp(seconds, 1, seconds)
	var speed = 1.0 / seconds

	$AnimationPlayer.playback_speed = speed

func light_actor():
	if opponent == player and current_line < 4:
		# slowly fade in self-doubt each line player speaks
		$ContentContainer/opponent.modulate.a = clamp(current_line - 1, 0, 3) * 0.23
		$ContentContainer/player.modulate = Color(1,1,1,1)
	elif fight_number == 1 and current_line < 2:
		# delay opponent for one line in fight #2 (1)
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate.a = 0.0
	elif opponent == "Ox_Anna" and current_line < 5:
		# Oksana shows up at line 5
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate.a = 0.0
	elif speaker == "player":
		$ContentContainer/player.modulate = Color(1,1,1,1)
		$ContentContainer/opponent.modulate = Color(0.55, 0.55, 0.55, 1)
	elif speaker == "opponent":
		$ContentContainer/opponent.modulate = Color(1,1,1,1)
		$ContentContainer/player.modulate = Color(0.55, 0.55, 0.55, 1)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name: # jovi
		"play exposition": # exposition is finished playing
			if opponent == "Ox_Anna":
				# change background to rooftop
				set_background("rooftop")
			next_action = "exposition to dialogue"
		"exposition to dialogue":
			$Exposition.text = ""
			next_action = "speak_line"
			speak_line()
		"dialogue to exposition":
			$AnimationPlayer.play("play exposition")
			$ContentContainer/player/AnimatedSprite.play("normal")
			$ContentContainer/opponent/AnimatedSprite.play("normal")
			if opponent == "Ox_Anna":
				$ContentContainer/opponent.modulate = Color(0.55, 0.55, 0.55, 1)
		"fade to dialogue":
			next_action = "speak_line"
			speak_line()
		"speak":
			next_action = "speak_line"
		"vs":
			get_tree().get_root().get_node("GameController").storymode_to_fight_scene()
			get_parent().get_parent().conversation_done()


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
