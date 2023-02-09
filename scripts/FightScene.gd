extends Node2D

var player1 # the node
var player2 # the node
var selected_player1 # a character name
var selected_player2 # a character name
var player1_wins = 0 # win counter
var player2_wins = 0 # win counter

const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 20

var fighting = false # for _process()
var match_type # storymode, deathmatch, or ai_vs_ai; only affects what happens after match
var background # background image

func set_match_type(type:String):
	match_type = type

func set_selected_player1(playerName:String):
	selected_player1 = playerName

func set_selected_player2(playerName:String):
	selected_player2 = playerName

func set_background(background:String):
	$Background.texture = load("res://levels/backgrounds/%s.jpg" % background)

func _process(_delta):
	if fighting: # only calculate positioning if the fight is on
		if player1.position.x <= player2.position.x:
			if player1.is_on_floor():
				player1.facing = "right"
				player1.scale = Vector2(abs(player1.scale.x), abs(player1.scale.y))
				player1.rotation_degrees = 0
			if player2.is_on_floor():
				player2.facing = "left"
				player2.scale = Vector2(abs(player2.scale.x), -abs(player2.scale.y))
				player2.rotation_degrees = 180
		else:
			if player1.is_on_floor():
				player1.facing = "left"
				player1.scale = Vector2(abs(player1.scale.x), -abs(player1.scale.y))
				player1.rotation_degrees = 180
			if player2.is_on_floor():
				player2.facing = "right"
				player2.scale = Vector2(abs(player2.scale.x), abs(player2.scale.y))
				player2.rotation_degrees = 0

func addPlayer(character, name, bot):
	# collision is the starting number of the four-set
	var scenePath = "res://characters/%s/%s.tscn" % [character, character]
	var player = load(scenePath).instance()
	player.name = name
	player.bot = bot
	if bot:
		player.script = load("res://scripts/AI.gd")
	player.character_name = character
	add_child(player)
	
	if name == "p1":
		player.collision_layer = 1
		player.collision_mask = 16
		player.get_node("HitBox").collision_mask = 64
		player.get_node("AttackCircle").collision_layer = 4
		player.position = Vector2(90, 360)
	else:
		player.collision_layer = 16
		player.collision_mask = 1
		player.get_node("HitBox").collision_mask = 4
		player.get_node("AttackCircle").collision_layer = 64
		player.scale.x *= -1 # flip player two
		player.position = Vector2(934, 360)
		
	return player

func start_fight():
	fighting = true
	$AnimationPlayer.play("RoundFight")

func choose_random_player():
	var characters = ["John","Kelsie","Terje"]
	var random = RandomNumberGenerator.new()
	random.randomize()
	characters.shuffle()
	return characters[random.randi_range(0, characters.size()-1)]

func choose_random_background():
	var backgrounds = ["arrivals","breakRoom","courtyard","hallway","humanHistory","lobby","naturalHistory","officeSpace","parking","roundhouse","shop"]
	var random = RandomNumberGenerator.new()
	random.randomize()
	backgrounds.shuffle()
	return backgrounds[random.randi_range(0, backgrounds.size()-1)]

func prepare_fight():
	if match_type == null:
		set_match_type("ai_vs_ai")
	if selected_player1 == null:
		set_selected_player1(choose_random_player())
	if selected_player2 == null:
		set_selected_player2(choose_random_player())
	if $Background.texture == null:
		set_background(choose_random_background())
	
	if player1: # clear them if they exist (fight reset up to 3 rounds)
		remove_child(player1)
		remove_child(player2)
	
	match match_type:
		"ai_vs_ai":
			player1 = addPlayer(selected_player1, "p1", true)
			player2 = addPlayer(selected_player2, "p2", true)
		"deathmatch","storymode":
			player1 = addPlayer(selected_player1, "p1", false)
			player2 = addPlayer(selected_player2, "p2", true)
		"multiplayer":
			print("TO WRITE")
			pass
		
	$UI.set_player_name(1, selected_player1)
	player1.health = 100
	$UI.set_player_health(1, 100)
	
	if player1_wins == 1:
		$UI.show_skull(1)
		
	$UI.set_player_name(2, selected_player2)
	player2.health = 100
	$UI.set_player_health(2, 100)
	
	if player2_wins == 1:
		$UI.show_skull(2)
		
	if selected_player1 == selected_player2:
		if match_type == "deathmatch" or match_type == "ai_vs_ai":
			if selected_player1 == "Terje":
				$UI.set_player_name(2, "Terry B")
			else:
				$UI.set_player_name(2, "Nega" + selected_player2)
		elif match_type == "storymode":
			$UI.set_player_name(2, "%s's Self-doubt" % selected_player1)
		var smoke = $p2.get_node("NegaSmoke")
		smoke.visible = true
		smoke.play()
	
	player1.enemy = player2
	player2.enemy = player1
	
	start_fight()

func show_round():
	format_text_for_label("ROUND %s" % (player1_wins + player2_wins + 1))

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
	
func hit_gong():
	$Gong.play()

func free_players():
	player1.match_over = false
	player2.match_over = false

func damageTaken(player, damage):
	if player.isStunned:
		if player.get_node("Timer"):
			player.get_node("Timer").queue_free()
		player.collapse()
	else:
		player.health -= damage
			
		if player.health < 0:
			player.health = 0
		
		if player.name == player1.name:
			$UI.set_player_health(1, player.health)
			player2.z_index = 2
			player1.z_index = 1
		else:
			$UI.set_player_health(2, player.health)
			player1.z_index = 2
			player2.z_index = 1
			
		if player.health <= 0:
			if (player == player1 && player2_wins == 1) or (player == player2 && player1_wins == 1):
				player.setStunned(true)
				player.enemy.can_use_fatality = true
				var timer = Timer.new()
				timer.name = "Timer"
				timer.wait_time = 5
				timer.one_shot = true
				var _unused = timer.connect("timeout", player, "collapse")
				player.add_child(timer)
				timer.start()
			else:
				player.collapse()

func match_over(player, winner):
	# freeze players
	player1.match_over = true
	player2.match_over = true
	
	if match_type == "ai_vs_ai":
		close_out_game()
	elif winner:
		if player == player1:
			player1_wins += 1
			if player1_wins == 2:
				player1.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(1))
				$NextMatchTimer.start()
		else:
			player2_wins += 1
			if player2_wins == 2:
				player2.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(2))
				$NextMatchTimer.start()
			
	else:
		if player == player1:
			player2_wins += 1
			if player2_wins == 2:
				player2.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(2))
				$NextMatchTimer.start()
		else:
			player1_wins += 1
			if player1_wins == 2:
				player1.victory()
				close_out_game()
			else:
				format_text_for_label("%s WINS!" % $UI.get_player_name(1))
				$NextMatchTimer.start()

func clear_label():
	$HBoxContainer/Label.visible = false
	$HBoxContainer/Label.text = ""

func format_text_for_label(text:String):
	clear_label()
	var width = text.length() * 50
	$HBoxContainer/Label.rect_min_size.x = width
	$HBoxContainer/Label.text = text.to_upper()
	$HBoxContainer/Label.visible = true

func close_out_game():
	$EndFightTimer.start()

func _on_NextMatchTimer_timeout():
	prepare_fight()

func _on_EndFightTimer_timeout():
	get_parent().lower_fight_music()
	$AnimationPlayer.play("fade out")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade out":
			get_parent().fight_done()
