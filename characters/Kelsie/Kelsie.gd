extends "res://scripts/Player.gd"

var special_spam = 3
var dizzy_timer
var special_reset_timer

func special_used():
	if special_spam == 3:
		start_special_reset_timer()
		
	special_spam = special_spam - 1
	
	if special_spam == 0:
		dizzy()

func start_special_reset_timer():
	special_reset_timer = Timer.new()
	special_reset_timer.wait_time = 3
	special_reset_timer.one_shot = true
	special_reset_timer.connect("timeout", self, "reset_special_spam")
	add_child(special_reset_timer)
	special_reset_timer.start()

func dizzy():
	if special_reset_timer:
		special_reset_timer = null
	busy = true
	animTree.travel("stunned")
	dizzy_timer = Timer.new()
	dizzy_timer.wait_time = 3
	dizzy_timer.one_shot = true
	dizzy_timer.connect("timeout", self, "undizzy")
	add_child(dizzy_timer)
	dizzy_timer.start()

func undizzy():
	if dizzy_timer:
		dizzy_timer = null
	busy = false
	reset_special_spam()
	animTree.travel("idle")

func reset_special_spam():
	if special_reset_timer != null:
		special_reset_timer = null
	special_spam = 3

func fatality():
	animTree.travel("fatality")
	# cancel the parent timer to prevent collapse
	get_parent().get_node("Timer").stop()
	
	# place Kelsie highest so boot is over victim
	z_index = 1000
	
	# cancel the enemy's collapse timer
	enemy.get_node("Timer").stop()

func position_boot():
	# get the difference between the boot and Kelsie
	# and add that to Kelsie's position to get boot location
	# and add a little so the ankle hits the body
	var distance = abs(enemy.position.x - position.x)
	$Boot.position.x = distance + $Boot.texture.get_width() * 0.25
		
	$Boot.position.y = $Boot.texture.get_height() / -2

func drop_boot():
	$Boot.visible = true
	var tween = get_node("Tween")
	tween.interpolate_property($Boot, "position",
		$Boot.position, Vector2($Boot.position.x, -80), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	enemy.squish()
	tween.start()

func raise_boot():
	get_parent().format_text_for_label("such bootality!")
	get_parent().announcer("fatality")
	var tween = get_node("Tween")
	tween.interpolate_property($Boot, "position",
		$Boot.position, Vector2($Boot.position.x, -1500), 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()

func fatality_response_john():
	animTree.travel("response-john")

func one_squirt():
	var blood = enemy.get_node("BloodSquirt")
	blood.emitting = true
