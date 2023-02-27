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

var characters = ["John","Kelsie","Terje"]
var backgrounds = ["arrivals","breakRoom","humanHistory","lobby","naturalHistory","officeSpace","parking","roundhouse","shop"]
var background

var match_type
var game_controller
var storymode_controller

func _ready():
	player1_wins = 0
	player2_wins = 0

func _input(event):
	if not key_to_exit or event is InputEventMouse:
		return

	game_controller.fight_done()

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
	bkg = "officeSpace"
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
	if player1_name == null:
		randomize()
		set_player1(characters[randi() % characters.size()])
		#ai vs ai demo key to quit
		key_to_exit = true
	if player2_name == null:
		randomize()
		set_player2(characters[randi() % characters.size()])
	if background == null:
		randomize()
		set_background(backgrounds[randi() % backgrounds.size()])
	if match_type == null:
		match_type = "demo"

	$Background.texture = load("res://levels/backgrounds/%s.jpg" % background)
	
	if player1_node:
		remove_child(player1_node)
		player1_node.queue_free()
		remove_child(player2_node)
		player2_node.queue_free()
	
	match match_type:
		"demo":
			player1_node = addPlayer(player1_name, "player1", true)
			player2_node = addPlayer(player2_name, "player2", true)
		"storymode","deathmatch":
			player1_node = addPlayer(player1_name, "player1", false)
			player2_node = addPlayer(player2_name, "player2", true)
		"multiplayer":
			pass
	
	player1_node.enemy = player2_node
	player2_node.enemy = player1_node
	player1_node.will_collapse = false
	player2_node.will_collapse = false
	
	format_text_for_label("Round %s" % (player1_wins + player2_wins + 1))
	$AnimationPlayer.play("intro")

func update_health(player, health:int):
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
		winner = player2_node
		loser = player1_node
		player1_node.stunned()
		player1_node.fighting = false
		player2_node.can_use_fatality = true
		$FatalityTimer.start()
	else:
		# undeciding round
		player.fighting = false
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
	if player1_wins >= 2 or player2_wins >= 2:
		$AnimationPlayer.play("end match fade")
		game_controller.ambience_fade("out")
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
	var width = text.length() * 57
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
