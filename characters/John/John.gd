extends "res://scripts/Player.gd"

func shoot_bullets(shoot):
	if shoot:
		$SoundPlayer.stream = load("res://sounds/characters/John/shot.wav")
		$SoundPlayer.play()
		var distance_from_enemy = abs(enemy.position.x - position.x)
		var lifetime = distance_from_enemy / $Bullets.gravity.x
		$Bullets.lifetime = lifetime
		$Bullets.emitting = true
	else:
		$Bullets.emitting = false

func enemy_taking_bullet():
	if enemy.character_name != "F.U.G.U.M." and not enemy.isBlocking:
#		animTree.travel("hit-john-special")
		var random = RandomNumberGenerator.new()
		random.randomize()
		var enemy_name = enemy.character_name
		var random_texture = random.randi_range(1, 4)
		var texture = load("res://characters/%s/sprites/actions/hit-john-special/hit-john-special_0%s.png" % [enemy_name, random_texture])
		enemy.get_node("Sprite").texture = texture
		get_parent().damageTaken(enemy, 1)
		enemy.health -= 1

func fatality():
	# cancel the parent timer to prevent collapse
	get_parent().get_node("Timer").stop()
	
	# cancel the enemy's collapse timer
	if enemy.get_node("Timer"):
		enemy.get_node("Timer").queue_free()
	
	animTree.travel("fatality-start") # custom to John
	var random = RandomNumberGenerator.new()
	random.randomize()
	var punNum = random.randi_range(1, 6)
	$FatalityPlayer.stream = load("res://characters/John/sounds/punality%s.wav" % punNum)
	$FatalityPlayer.play()

func fatality_end():
	if enemy.character_name != "John":
		enemy.animTree.travel("response-john")
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 3.0
		timer.connect("timeout", self, "close_out_game")
		add_child(timer)
		timer.start()
		get_parent().format_text_for_label("punality")
		get_parent().announcer("punality")
	else:
		# delay a bit for comedic effect!
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		timer.connect("timeout", self, "punality")
		add_child(timer)
		timer.start()
		get_parent().format_text_for_label("friendship")
		
	animTree.travel("fatality-end")

func close_out_game():
	get_tree().get_root().get_node("Environment").close_out_game()

func punality():
	enemy.animTree.travel("response-john")
	close_out_game()

func _on_FatalityPlayer_finished():
	fatality_end()
