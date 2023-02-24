extends KinematicBody2D

const GRAVITY = 1000
const RUN_SPEED = 400
const WALK_SPEED = 150

var speed_modifier = 1.0
var character_name = "Ox Anna"
var health
var destination
var facing = "left"
var running = false
var entrance_complete = false
var moving_to_centre = false
var walk_away = false

var enemy
var got_hit = false
var fighting = false
var paw_counter

signal update_health(health)

func _ready():
	paw_counter = 0
	randomize()
	var _1 = connect("update_health", get_parent(), "update_health")
	$Coordinator.play("run")

func _physics_process(_delta):
	var velocity = Vector2()
	velocity.y += GRAVITY
	
	if running:
		var movement = RUN_SPEED * speed_modifier
		if facing == "left":
			velocity.x -= movement
		else:
			velocity.x += movement
		
		if facing == "left" and position.x <= 300:
			$Coordinator.play("slide stop")
			if position.x <= 100:
				turn()
		elif facing == "right" and position.x >= 600:
			$Coordinator.play("slide stop")
			if position.x >= 900:
				turn()
	elif entrance_complete == false:
		velocity.x -= WALK_SPEED
		
		if global_position.x <= 900:
			velocity.x = 0
			$Coordinator.play("idle")
			entrance_complete = true
	elif moving_to_centre:
		if facing == "right" and global_position.x < 512:
			velocity.x += WALK_SPEED
		elif facing == "left" and global_position.x > 512:
			velocity.x -= WALK_SPEED
		else:
			velocity.x = 0
			$Coordinator.play("idle")
			moving_to_centre = false
	elif walk_away:
		if abs(global_position.x) - abs(enemy.global_position.x) < 3:
			moo()
			
		if facing == "right" and global_position.x < 1300:
			velocity.x += WALK_SPEED * 0.7
		elif facing == "left" and global_position.x > -300:
			velocity.x -= WALK_SPEED * 0.7
		else:
			velocity.x = 0
#	elif fighting == false:
#		$Coordinator.play("idle")
#		velocity.x = 0
	
	var _result = move_and_slide(velocity, Vector2.UP)

func _on_ChargeTimer_timeout():
	$HeadDown.set_deferred("monitoring", true)
	var random = RandomNumberGenerator.new()
	random.randomize()
	paw_counter = random.randi_range(0,3)
	$Coordinator.play("pawing")

func move_to_centre():
	moving_to_centre = true
	$Coordinator.play("run")

func turn():
	running = false
	got_hit = false
	modulate = Color(1,1,1,1) # just in case
	speed_modifier *= 1.1
	scale.x = -scale.x
	if facing == "right":
		facing = "left"
	else:
		facing = "right"
	$Coordinator.playback_speed = 1
	$Coordinator.play("idle")
	if fighting:
		$ChargeTimer.start()

func damage_taken(animation:String):
	if animation == "uppercut":
		if got_hit:
			return

		got_hit = true
		$Coordinator.play("hit")
		health -= 25
		speed_modifier *= 1.1
		emit_signal("update_health", self, health)
		enemy.play_sound("res://sounds/characters/effects/punched.wav", true)
		moo()

func pawing_sound():
	$SoundPlayer.stream = load("res://sounds/characters/Ox_Anna/pawing.wav")
	$SoundPlayer.pitch_scale = rand_range(0.8, 1.2)
	$SoundPlayer.play()

func moo():
	if $SoundPlayer.playing:
		return
		
	$SoundPlayer.stream = load("res://sounds/characters/Ox_Anna/moo_%s.wav" % (randi() % 4))
	$SoundPlayer.pitch_scale = rand_range(0.8, 1.2)
	$SoundPlayer.play()

func collapse():
	$ChargeTimer.stop()
	running = false
	fighting = false
	$Coordinator.play("collapse")

func is_getting_shot(_meh):
	# moo! ignore, as it does nothing and goes over her head anyhow
	pass

func _on_Gore_body_entered(_body):
	if not running:
		return
		
	if not got_hit:
		$ChargeTimer.stop()
		$HeadDown.set_deferred("monitoring", false)
		$Coordinator.play("goring")
		enemy.damage_taken("tossed-by-oxanna")

func roasted():
	$Coordinator.play("roasted")
	
func play_anthem():
	$Anthem.play()

func _on_HeadDown_body_entered(_body):
	if running:
		$Coordinator.play("head down")
	else:
		# if player gets too close, we charge right away
		$ChargeTimer.stop()
		$Coordinator.play("run")
		running = true
		paw_counter = 0

func _on_Coordinator_animation_finished(anim_name):
	match anim_name:
		"pawing":
			if paw_counter == 0:
				$Coordinator.play("run")
				$Coordinator.playback_speed = speed_modifier
				running = true
			else:
				paw_counter -= 1
				$Coordinator.play("pawing")
				running = false
			return
		"goring":
			return
		"victory":
			$Coordinator.play("back down")
			running = false
			return
		"back down":
			$Coordinator.play("run")
			$Head.visible = true
			walk_away = true
			running = false
			return
		"collapse":
			fighting = false
			running = false
			return

func _on_HeadDown_body_exited(_body):
	$Head/HeadPlayer.play("idle")
	$HeadDown.set_deferred("monitoring", false)
