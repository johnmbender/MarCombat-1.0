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
var running_away = 1 # speed modifier, updated if Ox is fleeing

var enemy
var got_hit = false
var fighting = false
var paw_counter

signal update_health(health)

func _ready():
	paw_counter = 0
	randomize()
	var _1 = connect("update_health", get_parent(), "update_health")
	$Coordinator.play("run") # but just walking in
	galloping(true)

func _physics_process(_delta):
	var velocity = Vector2()
	velocity.y += GRAVITY
	
	if running:
		var movement = clamp(RUN_SPEED * speed_modifier * running_away, RUN_SPEED, 800)
		if facing == "left":
			velocity.x -= movement
		else:
			velocity.x += movement
		
		if facing == "left" and position.x <= 300:
			if enemy.get_node("AnimationPlayer").current_animation == "tossed-by-oxanna":
				galloping(false)
				$Coordinator.play("slide stop")
			if position.x <= 100:
				running_away = 1
				turn()
		elif facing == "right" and position.x >= 600:
			if enemy.get_node("AnimationPlayer").current_animation == "tossed-by-oxanna":
				galloping(false)
				$Coordinator.play("slide stop")
			if position.x >= 900:
				running_away = 1
				turn()
	elif entrance_complete == false:
		velocity.x -= WALK_SPEED
		
		if global_position.x <= 900:
			velocity.x = 0
			$Coordinator.play("idle")
			entrance_complete = true
			galloping(false)
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
	
	var _result = move_and_slide(velocity, Vector2.UP)

func _on_ChargeTimer_timeout():
	var random = RandomNumberGenerator.new()
	random.randomize()
	paw_counter = random.randi_range(0,3)
	$Coordinator.play("pawing")

func move_to_centre():
	moving_to_centre = true
	$Coordinator.play("run")

func turn():
	galloping(false)
	$HeadDown.set_deferred("monitoring", true)
	$Gore.set_deferred("monitoring", true)
	$RunAway.set_deferred("monitoring", false)
	
	got_hit = false
	speed_modifier *= 1.15
	scale.x = -scale.x
	if facing == "right":
		facing = "left"
	else:
		facing = "right"
	
	if running_away == 1:
		# NOT running away
		running = false
		$Coordinator.playback_speed = 1
		$Coordinator.play("idle")
		
		if fighting:
			$ChargeTimer.start()
	else:
		# running away
		$ChargeTimer.stop()
		$Coordinator.playback_speed = 4
		$Coordinator.play("run")

func damage_taken(animation:String):
	if animation == "uppercut":
		if got_hit:
			return

		galloping(false)
		got_hit = true
		$Coordinator.play("hit")
		running = false
		# don't trigger a runaway until after get up
		$RunAway.set_deferred("monitoring", false)
		$HeadDown.set_deferred("monitoring", false)
		$Gore.set_deferred("monitoring", false)
		health -= 25
		speed_modifier *= 1.15
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
	$SoundPlayer.pitch_scale = rand_range(0.8, 1.3)
	$SoundPlayer.play()

func collapse():
	$ChargeTimer.stop()
	running = false
	running_away = 1
	fighting = false
	$Coordinator.play("collapse")

func is_getting_shot(_meh):
	# moo! ignore, as it does nothing and goes over her head anyhow
	print("BOVINE INTERVENTION!")
	pass

func _on_Gore_body_entered(_body):
	if not running:
		return
		
	if not got_hit:
		$ChargeTimer.stop()
		$HeadDown.set_deferred("monitoring", false)
		$Coordinator.play("goring")
		$RunAway.set_deferred("monitoring", false)
		
		enemy.damage_taken("tossed-by-oxanna")

func _on_Gore_body_exited(body):
	if body != enemy:
		return
		
	$Gore.set_deferred("monitoring", false)

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
		galloping(true)
		paw_counter = 0

func _on_Coordinator_animation_finished(anim_name):
	match anim_name:
		"pawing":
			if paw_counter == 0:
				$Coordinator.play("run")
				$Coordinator.playback_speed = speed_modifier
				running = true
				galloping(true)
			else:
				paw_counter -= 1
				$Coordinator.play("pawing")
				running = false
			return
		"goring":
			return
		"hit":
			$Coordinator.play("collapse")
			return # necessary?
		"get up":
			running_away = 1
			running = true
			galloping(true)
			$Coordinator.play("run")
			$RunAway.set_deferred("monitoring", true)
			return
		"victory":
			$Coordinator.play("back down")
			running = false
			return
		"back down": # back to all fours after anthem
			$Coordinator.play("run")
			$Head.visible = true
			walk_away = true
			running = false
			return
		"collapse":
			if health > 0:
				# hit and knocked down but fight not over
				$Coordinator.play("get up")
			else:
				fighting = false
				running = false
				return

func _on_HeadDown_body_exited(body):
	if body != enemy:
		return
		
	$Head/HeadPlayer.play("idle")
	$HeadDown.set_deferred("monitoring", false)

func _on_RunAway_body_entered(body):
	if body != enemy:
		return
		
	# if player is in this area, Ox should run quickly away
	$RunAway.set_deferred("monitoring", false)
	turn()
	running = true
	galloping(true)
	$Coordinator.play("run")
	running_away = 5

func galloping(yes:bool):
	if yes:
		$SoundPlayer.stream = load("res://sounds/characters/Ox_Anna/gallop.wav")
		$SoundPlayer.volume_db = -7
		$SoundPlayer.pitch_scale = clamp(speed_modifier - 0.3, 0.7, 1.4)
		$SoundPlayer.play()
	else:
		$SoundPlayer.stop()
		$SoundPlayer.volume_db = 0

func disable_collisions():
	$HeadDown.set_deferred("monitoring", false)
	$Gore.set_deferred("monitoring", false)
	$RunAway.set_deferred("monitoring", false)
