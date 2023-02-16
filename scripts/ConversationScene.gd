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
	get_node(role).add_child(scene)
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

		scene.global_position = position

func load_script(role:String):
	var node = get_node("%s/AnimatedSprite" % role)
	var dialogue = node.get_dialogue(role, fight_number)
	if role == "player":
		player_pronouns = node.get_pronouns()
	else:
		opponent_pronouns = node.get_pronouns()
		
	return dialogue

func set_background(bkg:String):
	$Background.texture = load("res://levels/backgrounds/%s.jpg" % bkg)
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
	speak_line()

func set_exposition():
	exposition = {
		0: {
			0: {
				"line": "One day, %s comes up with the best idea ever.\n\n%s idea would skyrocket the prestige of the museum, make it highly profitable, and spike morale. It's risk-free and nearly at zero cost.\n\n%s wants to run the idea past a coworker before taking it up the line.\n\n%s finds %s and explains it to %s, who cheerfully provides a lot of constructive feedback..." % [player, player_pronouns[2], player_pronouns[0], player_pronouns[0], opponent, opponent_pronouns[1]],
			}
		},
		1: {
			4: {
				"line": "%s explains %s brilliant idea to %s, carefully watching %s response." % [player, player_pronouns[2], opponent, opponent_pronouns[2]]
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

func _input(event):
	if event is InputEventMouse:
		pass # so dumb
	elif $AnimationPlayer.playback_speed < 100:
		$AnimationPlayer.playback_speed = 100
	elif next_action:
		match next_action:
			"speak_line":
				speak_line()
			"fade in from exposition":
				$AnimationPlayer.play("fade in from exposition")
		$AnimationPlayer.playback_speed = 1
		next_action = null

func speak_line():
	if current_line >= scene_script.size():
		$AnimationPlayer.play("vs")
	else:
		var line = scene_script[current_line]
		var role = line["role"]

		if role == "exposition":
			if current_line > 0:
				$AnimationPlayer.play("fade to exposition")
				$Exposition.text = line["line"]
				$Exposition.modulate = Color(1,1,1,1)
				$DialogueBox/Dialogue.text = ""
				$DialogueBox/Dialogue.percent_visible = 0
			else:
				# we do these things for conversation scenes that
				# start with an exposition, like the intro
				$Exposition.text = line["line"]
				set_speaking_speed(line["line"])
				$AnimationPlayer.play("play exposition")
				$Exposition.modulate = Color(1,1,1,1)
			
			current_line += 1
		else:
			if current_line == 0 and line["role"] != "exposition" and $Background.self_modulate == Color(1,1,1,0):
				$AnimationPlayer.play("fade in dialogue")
			else:
				var action = line["action"]
				var text = line["line"]
				get_node("%s/AnimatedSprite" % role).play(action)
				
				if text != null:
					if "%" in text:
						if role == "player":
							text = text % opponent
						else:
							text = text % player
					$DialogueBox/Dialogue.text = text
					set_speaking_speed(text)
					speaker = role
					light_actor()
					$AnimationPlayer.play("speak")
					current_line += 1
				
				if action == "fight":
					get_node(role).modulate = Color(1,1,1,1)
					$DialogueBox.modulate = Color(0,0,0,0)
					current_line += 1
					speak_line()

func set_speaking_speed(text:String):
	var chars = text.length()
	var speed = 1
	if chars > 0:
		var chars_per_sec = 25
		var seconds = float(chars) / chars_per_sec
		seconds = clamp(seconds, 1, seconds)
		speed = 1.0 / seconds

	$AnimationPlayer.playback_speed = speed

func light_actor():
	if player == opponent and speaker == opponent:
		$opponent.modulate = Color(0.5, 0.5, 0.5, .7)
	else:
		get_node(speaker).modulate = Color(1, 1, 1, 1)
	
	if player == opponent and speaker != "opponent":
		# self-doubt hides until the end
		$opponent.modulate = Color(0,0,0,0)
	
	if speaker == "player":
		if (fight_number == 1 and current_line == 0) or (player == opponent and current_line < 4):
			# not there until after first line of second scene
			$opponent.modulate = Color(0.55, 0.55, 0.55, 0)
		else:
			$opponent.modulate = Color(0.55, 0.55, 0.55, 1)
	else:
		$player.modulate = Color(0.55, 0.55, 0.55, 1)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"play exposition": # exposition is finished playing
			next_action = "fade in from exposition"
		"fade in from exposition":
			$Exposition.text = ""
			speak_line()
		"fade to exposition":
			$AnimationPlayer.play("play exposition")
		"fade in dialogue":
			speak_line()
		"speak":
			next_action = "speak_line"
		"vs":
			get_parent().get_parent().conversation_done()
