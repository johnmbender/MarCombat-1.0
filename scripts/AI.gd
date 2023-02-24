extends "res://scripts/Player.gd"

var aggression = 0.8
var block_chance = 0.4
var defensiveness = 0.2
var actionTimer:Timer

var action

func _ready():
	action = "wait"
	actionTimer = Timer.new()
	actionTimer.one_shot = true
	actionTimer.autostart = false
	var _u = actionTimer.connect("timeout", self, "doSomething")
	actionTimer.name = "ActionTimer"
	add_child(actionTimer)

func set_enemy(e):
	enemy = e

func doSomething():
	if not fighting:
		action = null
		return
	
	var roll = randf()
	if enemy_in_range():
		if roll <= defensiveness:
			action = "back up"
		elif roll <= aggression:
			action = "attack"
		else:
			action = "wait"
	else:
		if roll <= defensiveness:
			action = "special"
		elif roll <= aggression:
			action = "approach"
		else:
			action = "wait"
	
	blocking = false
	crouching = false

func _physics_process(_delta):
	velocity = Vector2()
	velocity.y = 0
	velocity.y += GRAVITY

	if attacking or blocking or crouching:
		return
		
	if blocking and action != "block":
		unblock()
	elif action == "approach":
		$AnimationPlayer.play("walk-forward")
		if enemy.global_position.x < (global_position.x - 100):
			velocity.x -= MOVE_SPEED
		elif enemy.global_position.x > (global_position.x + 100):
			velocity.x += MOVE_SPEED
		else:
			bot_next_action()
			velocity.x = 0
	elif action == "back up":
		$AnimationPlayer.play("walk-backward")
		if enemy.global_position.x < global_position.x:
			velocity.x += MOVE_SPEED
		elif enemy.global_position.x > global_position.x:
			velocity.x -= MOVE_SPEED
		else:
			bot_next_action()
			velocity.x = 0
		
		if name == "player2" and global_position.x > 800:
			bot_next_action()
		elif name == "player1" and global_position.x <= 150:
			bot_next_action()
	elif action == "attack" and not attacking:
		attack()
	elif action == "special":
		special()
	elif action == "block":
		block()
	elif action == "wait":
		wait()
	
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
		$AnimationPlayer.play("uppercut")
	else:
		$AnimationPlayer.play("punch%s" % modifier)
	
	action = "wait"

func wait():
	$AnimationPlayer.play("idle")
	bot_next_action()

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
	bot_stop_timer()
	
	var enemy_action = enemy.get_node("AnimationPlayer").current_animation
	if blockable.has(enemy_action) and rand_range(0, 1.0) < block_chance:
		action = "block"
		blocking = true
	else:
		action = "wait"
		bot_next_action()

func bot_stop_timer():
	if action != "approach" and action != "back up":
		action = null
	$ActionTimer.stop()

func bot_next_action():
	$ActionTimer.wait_time = rand_range(0.001, 1.5)
	$ActionTimer.start()

func enemy_in_range():
	return abs(enemy.global_position.x - global_position.x) < 250
