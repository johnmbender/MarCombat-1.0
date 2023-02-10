extends "res://scripts/TestPlayer.gd"

var aggression = 0.7
var block_chance = 0.4
var defensiveness = 0.2
var quickness = 0.7 # what for?
var actionTimer:Timer

var action

func _ready():
	action = "wait"
	actionTimer = Timer.new()
	actionTimer.one_shot = true
	actionTimer.wait_time = rand_range(0.1, 1.0)
	var _unused = actionTimer.connect("timeout", self, "doSomething")
	add_child(actionTimer)
	actionTimer.start()

func set_enemy(e):
	enemy = e

func doSomething():
	var roll = randf()
	if enemy_in_range():
		if roll <= defensiveness:
			action = "back up"
		elif roll <= aggression:
			action = "attack"
		else:
			action = "wait"
	else:
		if roll <= aggression:
			action = "approach"
		elif roll <= 0.9:
			action = "special"
		else:
			action = "wait"
	
	actionTimer.wait_time = rand_range(0.1, 1.0)
	actionTimer.start()

func _physics_process(_delta):
	velocity = Vector2()
	velocity.y += GRAVITY
	
	if blocking and action != "block":
		unblock()
	elif action == "approach":
		$AnimationPlayer.play("walk-forward")
		if enemy.global_position.x < (global_position.x - 100):
			velocity.x -= MOVE_SPEED
		elif enemy.global_position.x > (global_position.x + 100):
			velocity.x += MOVE_SPEED
		else:
			action = "wait"
			velocity.x = 0
	elif action == "back up":
		$AnimationPlayer.play("walk-backward")
		if enemy.global_position.x < global_position.x:
			velocity.x += MOVE_SPEED
		elif enemy.global_position.x < global_position.x:
			velocity.x -= MOVE_SPEED
		else:
			action = "wait"
			velocity.x = 0
	elif action == "attack" and not attacking:
		attack()
#	elif action == "special": BROKEN
#		special()
	elif action == "block":
		block()
			
	var _unused = move_and_slide(velocity, Vector2.UP)

func attack():
	attacking = true
	var modifier = "-far"
	if enemy_is_close():
		modifier = "-close"
		
	if rand_range(0.0, 1.0) > 0.6:
		$AnimationPlayer.play("kick%s" % modifier)
	else:
		$AnimationPlayer.play("punch%s" % modifier)

func wait():
	$AnimationPlayer.play("idle")

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
	actionTimer.stop()
	
	var enemy_action = enemy.get_node("AnimationPlayer").current_animation
	if blockable.has(enemy_action) and randf() < block_chance:
		action = "block"
	else:
		action = "wait"

func bot_resume_action_timer():
	actionTimer.wait_time = 0.001
	actionTimer.start()

func enemy_in_range():
	return abs(enemy.global_position.x - global_position.x) < 300
