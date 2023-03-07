extends "res://scripts/Player.gd"

var aggression # = 0.8
var block_chance # = 0.25
var defensiveness # = 0.2
var actionTimer:Timer
var actionTimer_wait_time = 0.6
# if doSomething finds completed_animation == false, 3 times
# we change it to true, to make sure bot doesn't get locked
var freeze_check = 4

var action

func _ready():
	action = null
	actionTimer = Timer.new()
	actionTimer.one_shot = false
	actionTimer.autostart = false
	actionTimer.wait_time = actionTimer_wait_time
	var _u = actionTimer.connect("timeout", self, "doSomething")
	actionTimer.name = "ActionTimer"
	add_child(actionTimer)
	$ActionTimer.start()
	
	randomizeTraits()

func randomizeTraits():
	var random = RandomNumberGenerator.new()
	random.randomize()
	aggression = random.randf_range(0.6, 0.9)
	block_chance = random.randf_range(0.2, 0.35)
	defensiveness = random.randf_range(0.1, 0.3)

func set_enemy(e):
	enemy = e

func doSomething():
	if not fighting:
		action = null
		return
		
	if completed_animation == false:
		freeze_check -= 1
		if freeze_check <= 0:
			freeze_check = 4
			completed_animation = true
		else:
			return
	else:
		freeze_check = 4
	
	var roll = randf()
	if enemy_in_range("striking"):
		if roll <= defensiveness:
			if facing == "left" && global_position.x < 700:
				action = "back up"
			elif facing == "right" && global_position.x > 200:
				action = "back up"
		elif roll <= aggression:
			action = "attack"
		else:
			action = null
	elif enemy_in_range("uncomfortable"):
		if facing == "left" && global_position.x < 700:
			action = "back up"
		elif facing == "right" && global_position.x > 200:
			action = "back up"
		else:
			action = "attack"
	else:
		if roll <= defensiveness:
			if _JOHN_guns_jammed or _KELSIE_is_dizzy or _TERJE_brochures_spilt or _TYLER_bees_tired:
				# very low chance for a bot to try their special too early
				if randf() < 0.05:
					if character_name == "Kelsie" and enemy_in_range("hair"):
						action = "special"
					else:
						action = "approach"
				else:
					action = "approach"
			else:
				action = "special"
		elif roll <= aggression:
			if abs(enemy.global_position.x - global_position.x) > 100:
				action = "approach"
			else:
				action = null
		else:
			action = null
			idle()
	
	blocking = false
	crouching = false

func _physics_process(_delta):
	velocity = Vector2()
	velocity.y = 0
	velocity.y += gravity

	if action == null or attacking or blocking or crouching:
		var _unused = move_and_slide(velocity, Vector2.UP)
		return
		
	if blocking and action != "block":
		unblock()
	elif action == "approach":
		$AnimationPlayer.play("walk-forward")
		
		if abs(enemy.global_position.x - global_position.x) > 100:
			if facing == "right":
				velocity.x += MOVE_SPEED
			else:
				velocity.x -= MOVE_SPEED
		else:
			velocity.x = 0
			action = null
			idle()
	elif action == "back up":
		$AnimationPlayer.play("walk-backward")
		if enemy.global_position.x < global_position.x:
			velocity.x += MOVE_SPEED
		elif enemy.global_position.x > global_position.x:
			velocity.x -= MOVE_SPEED
		elif name == "player2" and global_position.x >= 800:
			velocity.x = 0
			idle()
		elif name == "player1" and global_position.x <= 100:
			velocity.x = 0
			idle()
		else:
			velocity.x = 0
			idle()
	elif action == "attack" and not attacking:
		attack()
	elif action == "special":
		special()
	elif action == "block":
		block()
	else:
		idle()
	
	var _unused = move_and_slide(velocity, Vector2.UP)

func attack():
	attacking = true
	var modifier = "-far"
	var kick = 0.7
	var punch = 0.2
	
	if enemy_is_close():
		modifier = "-close"
	
	var roll = rand_range(0.0, 1.0)
	if roll > kick:
		$AnimationPlayer.play("kick%s" % modifier)
	elif roll < punch:
		if enemy_in_range("uppercut"):
			$AnimationPlayer.play("uppercut")
		else:
			$AnimationPlayer.play("punch%s" % modifier)
	else:
		$AnimationPlayer.play("punch%s" % modifier)
	
	action = null

func special():
	$AnimationPlayer.play("special")

func block():
	if not blocking:
		$AnimationPlayer.play("block")
		blocking = true

func unblock():
	if blocking:
		$AnimationPlayer.play("block-release")

func bot_damage_taken():
	var enemy_action = enemy.get_node("AnimationPlayer").current_animation
	if blockable.has(enemy_action) and rand_range(0, 1.0) < block_chance:
		action = "block"
		blocking = true
	else:
		action = null
		
	fighting = true

func enemy_in_range(relative:String):
	var distance = abs(enemy.global_position.x - global_position.x)
	
	match relative:
		"striking":
			return distance < 220
		"uppercut":
			return distance < 150
		"uncomfortable":
			return distance < 100
		"hair":
			return distance < 700
