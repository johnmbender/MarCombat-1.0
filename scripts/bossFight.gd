extends "res://scripts/Level.gd"

var boss

func _ready():
	bossFight = true

func _process(_delta):
	if player1.position.x <= boss.position.x:
		if player1.is_on_floor():
			player1.facing = "right"
			player1.scale = Vector2(abs(player1.scale.x), abs(player1.scale.y))
			player1.rotation_degrees = 0
	else:
		if player1.is_on_floor():
			player1.facing = "left"
			player1.scale = Vector2(abs(player1.scale.x), -abs(player1.scale.y))
			player1.rotation_degrees = 180

#		boss.scale = Vector2(abs(boss.scale.x), abs(boss.scale.y))
#		boss.rotation_degrees = 0

func addPlayer(character, name, bot, position):
	# collision is the starting number of the four-set
	var scenePath = "res://characters/%s/%s.tscn" % [character, character]
	var player = load(scenePath).instance()
	player.name = name
	player.position = position
	player.character_name = character
	add_child(player)
	
	if player.character_name != "Ox_Anna":
		player.collision_layer = 1
		player.collision_mask = 16
		player.get_node("HitBox").collision_mask = 64
#		player.remove_child(player.get_node("HitBox"))
		player.get_node("AttackCircle").collision_layer = 4
	else:
		player.collision_layer = 2
		player.get_node("AttackCircle").collision_layer = 64
		player.get_node("AttackCircle").collision_mask = 4
		
	return player

func start_game():
	reset_timer.stop()
	
	if player1:
		remove_child(player1)
		remove_child(boss)

	player1 = addPlayer(selected_player1, "p1", false, Vector2(90, 360))
	$UI.set_player_name(1, selected_player1)
	player1.health = 100
	$UI.set_player_health(1, 100)
	
	if player1_wins == 1:
		$UI.show_skull(1)
		
	boss = addPlayer("Ox_Anna", "p2", true, Vector2(934, 320))
	$UI.set_player_name(2, "Ox Anna")
	boss.health = 100
	$UI.set_player_health(2, 100)
	
	if player2_wins == 1:
		$UI.show_skull(2)
		
	player1.enemy = boss
	boss.enemy = player1
	
	$AnimationPlayer.play("RoundFight")

func announcer(speak:String):
	var stream
	match speak:
		"round":
			stream = "res://sounds/announcer/round%s.wav" % (player1_wins + player2_wins + 1)
		"fatality":
			stream = "res://sounds/announcer/fatality.wav"
		"punality":
			stream = "res://sounds/announcer/punality.wav"
	
	if stream != null:
		$Announcer.stream = load(stream)
		$Announcer.play()

func free_players():
	player1.match_over = false
	boss.match_over = false

func damageTaken(victim, damage):
	if victim.isStunned:
		if victim.get_node("Timer"):
			victim.get_node("Timer").queue_free()
		victim.collapse()
	else:
		victim.health -= damage
			
		if victim.health < 0:
			victim.health = 0
		
		if victim == player1:
			$UI.set_player_health(1, player1.health)
		else:
			$UI.set_player_health(2, boss.health)
			
		if victim.health <= 0:
			if victim == player1 && player1.enemy != boss:
				player1.setStunned(true)
				player1.enemy.can_use_fatality = true
				var timer = Timer.new()
				timer.name = "Timer"
				timer.wait_time = 5
				timer.one_shot = true
				var _unused = timer.connect("timeout", player1, "collapse")
				player1.add_child(timer)
				timer.start()
			else:
				player1.collapse()

func match_over(character, winner):
	# freeze players
	player1.match_over = true
	boss.match_over = true

	if winner:
		if character == player1:
			player1_wins += 1
			if player1_wins == 2:
				player1.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(1))
				reset_timer.start()
		else:
			player2_wins += 1
			if player2_wins == 2:
				boss.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(2))
				reset_timer.start()
	else:
		if character == player1:
			player2_wins += 1
			if player2_wins == 2:
				player2.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(2))
				reset_timer.start()
		else:
			player1_wins += 1
			if player1_wins == 2:
				player1.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(1))
				reset_timer.start()
