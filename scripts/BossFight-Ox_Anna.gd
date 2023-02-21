extends Node2D

var player_wins
var boss_wins
var player
var player_name
var boss
var winner
var loser

func _ready():
	player_wins = 0
	boss_wins = 1

	# for now
	set_player("John")
	set_scene()

func set_player(name:String):
	player_name = name
	
func set_scene():
	if player:
		remove_child(player)
		remove_child(boss)

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
	
	if player_wins == 2:
		winner = player
		loser = boss
		loser.collapse()
		winner.victory()
		$EndFightTimer.start()
	elif boss_wins == 2:
		winner = boss
		loser = player
		player.stunned()
		player.fighting = false
		boss.victory()
	else:
		# undeciding round
#		character.collapse()
		character.enemy.fighting = false
		announcer_speak(character.enemy.character_name)
		$EndFightTimer.wait_time = 3
		$EndFightTimer.start()
#		character.fighting = false

func victory_scene():
	announcer_speak("Ox Anna")
	format_text_for_label("Ox Anna wins")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			$Ox_Anna/ChargeTimer.start()
			$Ox_Anna.fighting = true
			$Player.fighting = true
		"end match fade":
			if winner == player:
				if $Ox_Anna/Coordinator.current_animation == "roasted":
					get_parent().get_parent().fight_done()
				else:
					# now we fade back into the roasting scene
					$Background.modulate = Color(0.5, 0.5, 0.5, 1)
					$Player.modulate = Color(0.7, 0.7, 0.7, 1)
					$Background.texture = load("res://levels/backgrounds/rooftop-nighttime.jpg")
					$UI.visible = false
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
				get_parent().get_parent().fight_done()
		"fade in night":
			announcer_speak("barbeque")
			format_text_for_label("barbeque!")

func _process(_delta):
	if player.global_position.x <= boss.global_position.x and player.is_on_floor():
		player.facing = "right"
		player.scale = Vector2(abs(player.scale.x), abs(player.scale.y))
		player.rotation_degrees = 0
	elif player.is_on_floor():
		player.facing = "left"
		player.scale = Vector2(abs(player.scale.x), -abs(player.scale.y))
		player.rotation_degrees = 180

func _on_EndFightTimer_timeout():
	if player_wins == 2:
		# player won, so allow the fade
		$AnimationPlayer.play("end match fade")
	elif boss_wins == 2:
		pass
	else:
		$AnimationPlayer.play("fade to round")

func speak_correction():
	announcer_speak("Ox Anna correction")
	format_text_for_label("Oksana wins")

func _on_Announcer_finished():
	match $Announcer.stream.resource_path:
		"res://sounds/announcer/Ox Anna.wav":
			$Ox_Anna.moo()
			var delay = Timer.new()
			delay.wait_time = 1.0
			delay.one_shot = true
			delay.connect("timeout", self, "speak_correction")
			add_child(delay)
			delay.start()
		"res://sounds/announcer/Ox Anna correction.wav":
			print("walk to person")
		"res://sounds/announcer/teabag.wav":
			pass
