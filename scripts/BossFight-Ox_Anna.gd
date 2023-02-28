extends Node2D

var player_wins
var boss_wins
var player
var player_name
var boss
var winner
var loser
var continue_counter = 10
var game_controller
var storymode_controller
var end_game_input = false
var barbequed = false

func _ready():
	player_wins = 0
	boss_wins = 0

func set_game_controller(controller):
	game_controller = controller

func set_storymode_controller(controller):
	storymode_controller = controller

func set_player1(name:String):
	player_name = name

func set_player2(_n):
	# to make StoryModeController happy
	pass

func set_background(_n):
	# to make StoryModeController happy
	pass

func set_match_type(_n):
	# to make StoryModeController happy
	pass
	
func set_scene():
	if player:
		remove_child(player)
		player.queue_free()
		remove_child(boss)
		boss.queue_free()
		$HBoxContainer2/Countdown.text = "10"
		$UI.visible = true

	var scenePath = "res://characters/%s/%s.tscn" % [player_name, player_name]
	player = load(scenePath).instance()
	player.script = load("res://scripts/Player.gd")
	player.name = "Player"
	player.bot = false
	player.character_name = player_name
	add_child(player)
	player.scale = Vector2(0.8, 0.8)
	var attack_circle = player.get_node("AttackCircle")
	attack_circle.collision_layer = 2
	attack_circle.collision_mask = 16
	player.health = 100
	player.idle()

	$UI/Player1/HBoxContainer/Name.text = player_name
	if player_wins == 1:
		$UI/Player1/SkullContainer/Skull.visible = true
	$UI/Player1/HealthBar.value = 100
	
	player.position = Vector2(100, 370)
	player.collision_layer = 1
	player.get_node("AttackCircle").collision_layer = 16
	
	var bossPath = "res://characters/Ox_Anna/Ox_Anna.tscn"
	boss = load(bossPath).instance()
	boss.name = "Ox_Anna"
	add_child(boss)
	boss.scale = Vector2(0.8, 0.8)
	boss.health = 100
	$UI/Player2/HBoxContainer/Name.text = "Ox Anna"
	if boss_wins == 1:
		$UI/Player2/SkullContainer/Skull.visible = true
	$UI/Player2/HealthBar.value = 100
	$Ox_Anna.position = Vector2(1210, 350)
	
	player.enemy = boss
	boss.enemy = player

	format_text_for_label("Round %s" % (player_wins + boss_wins + 1))
	$AnimationPlayer.play("intro")

func _input(event):
	if end_game_input:
		if event is InputEventMouse:
			return # so dumb
			
		end_game_input = false
		reset()
		set_scene()

func reset():
	player_wins = 0
	boss_wins = 0
	$HBoxContainer2/CountdownTimer.stop()
	$HBoxContainer2/Countdown.visible = false
	$UI/Player1/SkullContainer/Skull.visible = false
	$UI/Player2/SkullContainer/Skull.visible = false
	game_controller.fight_music_adjust("raise")

func announcer_speak(line:String):
	var path = "res://sounds/announcer/"
	if line == "round":
		var round_number = player_wins + boss_wins + 1
		$Announcer.stream = load("%sround%s.wav" % [path, round_number])
	else:
		$Announcer.stream = load("%s%s.wav" % [path, line])
		
	$Announcer.playing = true

func format_text_for_label(text:String):
	var width = text.length() * 62
	$HBoxContainer/Words.rect_min_size.x = width
	$HBoxContainer/Words.rect_position.x = (1024 - width) / 2
	$HBoxContainer/Words.text = text.to_upper()
	$HBoxContainer/Words.visible = true

func update_health(character, health:int):
	if character.health <= 0:
		character.health = 0
		
	if character == player:
		$UI/Player1/HealthBar.value = health
	else:
		$UI/Player2/HealthBar.value = health
	
	if character.health > 0:
		return
	
	if character == player:
		# boss won round
		boss_wins += 1
	else:
		# player won round
		player_wins += 1
	
	if player_wins >= 2:
		winner = player
		loser = boss
		loser.collapse()
		# victory_timer delays the player's victory celebration
		# so they can get their uppercut animation done
		var victory_timer = Timer.new()
		victory_timer.wait_time = 1.0
		victory_timer.name = "VictoryTimer"
		victory_timer.one_shot = true
		victory_timer.connect("timeout", self, "delayed_victory")
		add_child(victory_timer)
		victory_timer.start()
		game_controller.fight_music_fade("out")
		$EndFightTimer.start()
	elif boss_wins >= 2:
		winner = boss
		loser = player
		player.fighting = false
		victory_scene()
	else:
		# undeciding round
		game_controller.fight_music_adjust("lower")
		if character == boss:
			$Ox_Anna.collapse()
		else:
			$Ox_Anna/ChargeTimer.stop()
			
		character.fighting = false
		character.enemy.fighting = false
		announcer_speak(character.enemy.character_name)
		$EndFightTimer.wait_time = 3
		$EndFightTimer.start()

func delayed_victory():
	$VictoryTimer.queue_free()
	winner.victory()

func victory_scene():
	$Ox_Anna.running = false
	$Ox_Anna/ChargeTimer.stop()
	$Ox_Anna.fighting = false
	announcer_speak("Ox Anna")
	format_text_for_label("Ox Anna wins")
	$Ox_Anna.move_to_centre()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			$Ox_Anna/ChargeTimer.start()
			$Ox_Anna.fighting = true
			$Player.fighting = true
		"end match fade":
			if winner == player:
				if barbequed:
					storymode_controller.fight_done()
				else:
					# now we fade back into the roasting scene
					game_controller.play_ambience("rooftop")
					$Background.modulate = Color(0.5, 0.5, 0.5, 1)
					$Player.modulate = Color(0.7, 0.7, 0.7, 1)
					$Background.texture = load("res://levels/backgrounds/rooftop-foreground.png")
					$UI.visible = false
					$Stars.visible = true
					$AnimationPlayer.play("fade in night")
					$Ox_Anna.roasted()
					$Ox_Anna.global_position.x = 600
					$Player.global_position.x = 300
					var anim
					match player.character_name:
						"John":
							anim = "yes"
						"Kelsie":
							anim = "flossing"
						"Terje":
							anim = "victory"
					$Player/AnimationPlayer.play(anim)
					$EndFightTimer.wait_time = 8
					$EndFightTimer.start()
			else:
				storymode_controller.fight_done()
		"fade in night":
			barbequed = true
			$Ox_Anna/SoundPlayer.stream = load("res://sounds/bbq-fire.wav")
			$Ox_Anna/SoundPlayer.volume_db = -5
			$Ox_Anna/SoundPlayer.play()
			announcer_speak("barbeque")
			format_text_for_label("barbeque!")

func _process(_delta):
	if end_game_input or $Ox_Anna/Anthem.is_playing():
		return
		
	if player.global_position.x <= boss.global_position.x and player.is_on_floor():
		player.facing = "right"
		player.scale = Vector2(abs(player.scale.x), abs(player.scale.y))
		player.rotation_degrees = 0
	elif player.is_on_floor():
		player.facing = "left"
		player.scale = Vector2(abs(player.scale.x), -abs(player.scale.y))
		player.rotation_degrees = 180

func _on_EndFightTimer_timeout():
	if player_wins >= 2:
		# player won, so allow the fade
		$AnimationPlayer.play("end match fade")
	elif boss_wins >= 2:
		format_text_for_label("continue?")
		$HBoxContainer.visible = true
		$HBoxContainer2/Countdown.visible = true
		$HBoxContainer2/CountdownTimer.start()
		announcer_speak("continue")
		end_game_input = true
	else:
		$AnimationPlayer.play("fade to round")

func speak_correction():
	announcer_speak("Ox Anna correction")
	$Delay.disconnect("timeout", self, "speak_correction")
	var _1 = $Delay.connect("timeout", self, "update_oksana")
	$Delay.start()
	$HBoxContainer/Words.text = ""
	game_controller.fight_music_fade("out")

func update_oksana():
	format_text_for_label("Oksana wins")
	$UI/Player2/HBoxContainer/Name.text = "Oksana"
	$Delay.disconnect("timeout", self, "update_oksana")

func _on_Announcer_finished():
	match $Announcer.stream.resource_path:
		"res://sounds/announcer/Ox Anna.wav":
			if boss_wins < 2:
				$Ox_Anna/Coordinator.play("idle")
				return
			$Ox_Anna.moo()
			var _1 = $Delay.connect("timeout", self, "speak_correction")
			$Delay.start()
		"res://sounds/announcer/Ox Anna correction.wav":
			$UI.visible = false
			$HBoxContainer.visible = false
			$Ox_Anna/Coordinator.play("victory")
			$EndFightTimer.wait_time = 15
			$EndFightTimer.start()

func _on_CountdownTimer_timeout():
	continue_counter -= 1
	
	if continue_counter == -1:
		$HBoxContainer2/CountdownTimer.stop()
		game_controller.storymode_quit()
	else:
		$HBoxContainer2/Countdown.text = "%s" % continue_counter
