extends "res://scripts/Player.gd"

var aggression = 0.8
var blockChance = 0.6
var defensiveness = 0.4
var quickness = 0.7
var random
var waiting = false
var actionTimer:Timer

var action

func _ready():
	action = "wait"
	random = RandomNumberGenerator.new()
	random.randomize()
	
	actionTimer = Timer.new()
	actionTimer.one_shot = false
	actionTimer.wait_time = rand_range(0.1, 1.0)
	actionTimer.connect("timeout", self, "doSomething")
	add_child(actionTimer)
	actionTimer.start()
	
func getInput():
	if busy or match_over:
		return
		
	match action:
		"back up":
			back_up()
		"attack":
			attack()
		"wait":
			wait()
		"approach":
			approach()
		"special":
			special()
		"block":
			block()

func setBusy(isBusy:bool):
	# override to stop actions
	if isBusy:
		action = null

	busy = isBusy


func doSomething():
	var roll = random.randf()
	if isClose():
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
		
func approach():
	if enemy.position.x < position.x:
		move("left")
	else:
		move("right")

func back_up():
	if enemy.position.x < position.x:
		move("right")
	else:
		move("left")

func attack():
	if rand_range(0.0, 1.0) > 0.6:
		kick()
	else:
		punch()

func wait():
	animTree.travel("idle")

func isClose():
	return abs(position.x - enemy.position.x) < 250
