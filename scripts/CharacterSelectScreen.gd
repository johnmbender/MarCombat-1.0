extends Node2D

var players
var overlay_positions
var overlay_position
var player_positions
var player_position
var timer
var enabled = true
var random
var bossFight = false

func _ready():
	# static horizontal locations
	player_positions = [184, 504, 820]
	
	random = RandomNumberGenerator.new()
	random.randomize()
	
	# (re)order the players
	players = ['John', 'Kelsie', 'Terje']
	players.shuffle()
	players.shuffle()
	
	var i = 0
	for p in players:
		var player = get_node(p)
		player.position = Vector2(player_positions[i], player.position.y)
		i = i + 1
		player.visible = true
	
	overlay_position = 0
	overlay_positions = [170, 500, 830]
	$"PlayerSelectOverlay-P1".position.x = overlay_positions[0]
	get_node(players[0]).playing = true

#func demo_mode():
#	var levelScene = preload("res://levels/WestEntrance.tscn")
#	var rand_char1 = players[random.randi_range(0,2)]
#	var rand_char2 = players[random.randi_range(0,2)]
#	var level = levelScene.instance()
#	level.selected_player1 = rand_char1
#	level.selected_player2 = rand_char2
#	level.demoMode = true
#	get_tree().change_scene_to(level)

func _process(delta):
	if enabled == true:
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()
		elif Input.is_action_just_pressed("cheat"):
			bossFight = true
		elif Input.is_action_just_pressed("right"):
			overlay_position += 1
			move_overlay()
		elif Input.is_action_just_pressed("left"):
			overlay_position -= 1
			move_overlay()
		elif Input.is_action_just_pressed("ui_accept"):
			var selected_player = players[overlay_position]
			$"PlayerSelectOverlay-P1".visible = false
			for player in players:
				if player != selected_player:
					get_node(player).visible = false
				else:
					get_node(player).play("selected")
			get_tree().get_root().get_node("LaunchScreen/AnimationPlayer").play("crossfadeMusic")
			enabled = false
			var delay = Timer.new()
			delay.wait_time = 2
			delay.one_shot = true
			delay.connect("timeout", self, "start_match")
			add_child(delay)
			delay.start()
			
func start_match():
	var level
	if bossFight == false:
		var levelScene = load("res://levels/WestEntrance.tscn")
		var character = players[overlay_position]
		var random_char = players[random.randi_range(0,2)]
		level = levelScene.instance()
		level.selected_player1 = players[overlay_position]
		level.selected_player2 = random_char
	else:
		var levelScene = load("res://levels/WestEntrance-bossFight.tscn")
		var character = players[overlay_position]
		var random_char = "OXana"
		level = levelScene.instance()
		level.selected_player1 = players[overlay_position]
		level.selected_player2 = random_char
		
	get_tree().get_root().add_child(level)
	get_tree().get_root().remove_child(self)
	
func move_overlay():
	if overlay_position >= players.size():
		overlay_position = 0
	elif overlay_position < 0:
		overlay_position = players.size() - 1
	
	$"PlayerSelectOverlay-P1".position.x = overlay_positions[overlay_position]
	set_active(players[overlay_position])
	
func set_active(player):
	for p in players:
		get_node(p).playing = false
		
	get_node(player).playing = true
