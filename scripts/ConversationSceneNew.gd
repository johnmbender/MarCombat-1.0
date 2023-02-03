extends Node2D

var scene_number
var scene_script

var player
var player_pronouns
var player_possessive
var player_script

var opponent
var opponent_pronouns
var opponent_possessive
var opponent_script

var background

var random
var exposition

var input_enabled
var sound_effect
var current_line

var speaker
var speaking_speed = 1

func _ready():
	# REMOVE LATER:
	# these will be set by StoryModeController
	set_scene(0)
	set_player("Kelsie")
	set_opponent("Terje")
	# END REMOVE LATER
	
	input_enabled = false
	current_line = 0
	set_exposition()
	scene_script = Array()
	merge_scripts()

	var backgrounds = ['arrivals', 'breakroom', 'courtyard', 'humanHistory', 'lobby', 'office', 'parking', 'roundhouse', 'shop']
	random = RandomNumberGenerator.new()
	random.randomize()
	var random_bkg = backgrounds[random.randi_range(0, backgrounds.size()-1)]
	$Background.texture = load("res://levels/backgrounds/%s.jpg" % random_bkg)
	set_background_sounds(random_bkg)
	
	if scene_number == 0:
		$AnimationPlayer.play("intro")
	else:
		$AnimationPlayer.play("fade in")

func _input(_event):
	if input_enabled:
		if $AnimationPlayer.playback_speed == 0:
			input_enabled = false
			resume_animation()

func set_scene(scene:int):
	scene_number = scene

func set_player(playerName:String):
	player = playerName
	load_scene(player, "player")
	player_script = load_script("player")

func set_opponent(playerName:String):
	opponent = playerName
	load_scene(opponent, "opponent")
	opponent_script = load_script("opponent")

func load_scene(character:String, role:String):
	var scene = load("res://characters/%s/%s-conversation.tscn" % [character, character]).instance()
	if role == "player":
		scene.flip_h = true
	get_node(role).add_child(scene)

func load_script(role:String):
	var node = get_node("%s/AnimatedSprite" % role)
	var dialogue = node.dialogue[role]['scene'][scene_number]['lines']
	if role == "player":
		player_pronouns = node.pronouns
	else:
		opponent_pronouns = node.pronouns
	return dialogue

func merge_scripts():
	var lines = player_script.size() + opponent_script.size()
	
	for n in range(0, lines):
		if player_script.has(n):
			player_script[n]['role'] = "player"
			scene_script.append(player_script[n])
		elif opponent_script.has(n):
			opponent_script[n]['role'] = "opponent"
			scene_script.append(opponent_script[n])

func set_background_sounds(location:String):
	#var backgrounds = ['arrivals', 'breakroom', 'courtyard', 'humanHistory', 'lobby', 'office', 'parking', 'roundhouse', 'shop']
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

func play_ambience():
	$Ambience.play()

func pause_animation():
	$AnimationPlayer.playback_speed = 0
	input_enabled = true

func resume_animation():
	$AnimationPlayer.playback_speed = 1
	input_enabled = false

func set_exposition():
	exposition = {
		0: {
			"intro": "One day, %s has a lightbulb moment and comes up with the best idea ever.\n\n%s idea would skyrocket the prestige of the museum, make it highly profitable, and spike morale. It's risk-free and at nearly zero cost.\n\n%s wants to run it past a coworker before taking it up the line.\n\n%s finds %s and explains it to %s, who cheerfully provides a lot of constructive feedback..." % [player, player_pronouns[2], player_pronouns[0], player_pronouns[0], opponent, opponent_pronouns[1]],
		}
	}

func write_exposition(event:String):
	var text = exposition[scene_number][event]
	$Exposition.text = text

func speak_line():
	if scene_script.has(current_line) == false:
		input_enabled = false
		load_fight_scene()
		$AnimationPlayer.play("start fight")
	else:
		var line = scene_script[current_line]
		
		var role = line["role"]
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
			$AnimationPlayer.play("speak")
		else:
			$DialogueBox.modulate = Color(1,1,1,0)
		
		current_line += 1
		
		# if no text was spoken, we're heading to a fight!
		if text == null:
			speak_line()

func set_speaking_speed(text:String):
	#not right - need %
	speaking_speed = 5 - (text.length() * 0.05)

func update_speed():
	$AnimationPlayer.playback_speed = speaking_speed

func light_actor():
	get_node(speaker).modulate = Color(1, 1, 1, 1)
	if speaker == "player":
		$opponent.modulate = Color(0.55, 0.55, 0.55, 1)
	else:
		$player.modulate = Color(0.55, 0.55, 0.55, 1)

func load_fight_scene():
	# prepare the battle, add to the StoryModeController
	# and let the animation finished function call start_fight()
	pass

func start_fight():
	# fade out, remove self... ?
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start fight":
		start_fight()
	else:
		speak_line()
