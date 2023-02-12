extends Node2D

var player1
var player1_wins
var player2
var player2_wins
var winner
var loser

var end_match = false

func _ready():
	player1_wins = 0
	player2_wins = 0
	set_scene()

func set_scene():
	if player1:
		remove_child(player1)
		remove_child(player2)
	
	var player1_scene = load("res://characters/John/John.tscn")
	player1 = player1_scene.instance()
	player1.script = load("res://scripts/TestPlayer.gd")
	add_child(player1)
	player1.idle()
	player1.set_name("John")
	player1.name = "player1"
	player1.set_bot(false)
	player1.set_health(100)
	$UI/Player1/HBoxContainer/Name.text = "John"
	if player1_wins == 1:
		$UI/Player1/SkullContainer/Skull.visible = true
	update_health(player1, 100)
	player1.position = Vector2(100, 370)
	player1.collision_layer = 1
	player1.collision_mask = 48
	player1.get_node("AttackCircle").collision_layer = 2
	
	#REMOVE LATER
	var player2_scene = load("res://characters/John/John.tscn")
	player2 = player2_scene.instance()
	player2.script = load("res://scripts/AI.gd")
	add_child(player2)
	player2.idle()
	player2.set_name("John")
	player2.name = "player2"
	player2.set_bot(true)
	player2.set_health(100)
	$UI/Player2/HBoxContainer/Name.text = "NegaJohn"
	if player2_wins == 1:
		$UI/Player2/SkullContainer/Skull.visible = true
	update_health(player2, 100)
	player2.position = Vector2(924, 370)
	player2.collision_layer = 16
	player2.collision_mask = 3
	player2.get_node("AttackCircle").collision_layer = 32
	
	player1.enemy = player2
	player2.set_enemy(player1)
	
	format_text_for_label("Round %s" % (player1_wins + player2_wins + 1))
	$AnimationPlayer.play("intro")

func update_health(player, health:int):
	if player.health <= 0:
		player.health = 0
		
	if player == player1:
		$UI/Player1/HealthBar.value = health
	else:
		$UI/Player2/HealthBar.value = health
	
	if player.health > 0:
		return
	
	# other play won fight
	if player == player1:
		player2_wins += 1
	else:
		player1_wins += 1
	
	if player1_wins == 2:
		winner = player1
		loser = player2
		player2.stunned()
		player2.fighting = false
		player1.can_use_fatality = true
		$FatalityTimer.start()
	elif player2_wins == 2:
		winner = player2
		loser = player1
		player1.stunned()
		player1.fighting = false
		player2.can_use_fatality = true
		$FatalityTimer.start()
	else:
		# undeciding round
		player.collapse()
		player.fighting = false
		player.enemy.fighting = false
		$EndFightTimer.wait_time = 3
		$EndFightTimer.start()

func _on_EndFightTimer_timeout():
	if player1_wins == 2 or player2_wins == 2:
		$AnimationPlayer.play("end match fade")
	else:
		$AnimationPlayer.play("fade to round")

func match_over(winner):
	$FatalityTimer.stop()
	winner.victory()
	format_text_for_label("%s wins" % winner.character_name)
	announcer_speak(winner.character_name)

func format_text_for_label(text:String):
	var width = text.length() * 70
	$HBoxContainer/Words.rect_min_size.x = width
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

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			player1.fighting = true
			player2.fighting = true
		"end match fade":
			print("aaaaand scene!")
#			get_parent().fight_done()

func _on_FatalityTimer_timeout():
	loser.collapse()
	winner.victory()
	$EndFightTimer.start()
