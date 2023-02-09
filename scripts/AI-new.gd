extends "res://scripts/TestPlayer.gd"

var aggression = 0.8
var blockChance = 0.6
var defensiveness = 0.4
var quickness = 0.7
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
	if enemy_is_close():
		if roll <= defensiveness:
			action = "back up"
		elif roll <= blockChance:
			action = "block"
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
	if action == "approach":
		$AnimationPlayer.play("walk-forward")
		if enemy.global_position.x < (global_position.x - 100):
			velocity.x -= MOVE_SPEED
		elif enemy.global_position.x > (global_position.x + 100):
			velocity.x += MOVE_SPEED
		else:
			action = "idle"
			velocity.x = 0
	elif action == "back up":
		$AnimationPlayer.play("walk-backward")
		if enemy.global_position.x < global_position.x:
			velocity.x += MOVE_SPEED
		elif enemy.global_position.x < global_position.x:
			velocity.x -= MOVE_SPEED
		else:
			action = "idle"
			velocity.x = 0
			
	var _unused = move_and_slide(velocity, Vector2.UP)

func attack():
	var modifier = ""
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

func bot_damage_taken():
	actionTimer.stop()
	action = "wait"

func bot_resume_action_timer():
	actionTimer.wait_time = 0.001
	actionTimer.start()
