extends KinematicBody2D

var gravity = 1000
const MOVE_SPEED = 300

const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 25

var facing
var fighting = false
var blocking = false
var crouching = false
var being_gored = false
var attacking
var completed_animation = true
var can_use_fatality = false
var will_collapse # in case of flying from uppercut, want to allow animation to finish

var bot
signal bot_damage_taken
signal update_health(health)
var enemy

# CHARACTER-SPECIFIC VARIABLES 
var _KELSIE_is_dizzy = false
var _JOHN_guns_jammed = false
var _TERJE_brochures_spilt = false
var _TYLER_bees_tired = false
var tyler_walking_away = false

var velocity
var free_animations = ["walk-backward","walk-forward","idle","crouch","crouching","crouch-return",] # list of animations that can be interrupted
var blockable = ["punch-far","kick-far","punch-close"]

var character_name
var health

var game_controller
var fight_controller

var upside_down = false

func set_game_controller(controller):
	game_controller = controller

func set_fight_controller(controller):
	fight_controller = controller

func _ready():
	var _1 = connect("update_health", get_parent(), "update_health")

func set_health(h:int):
	health = h

func idle():
	$AttackCircle.set_deferred("monitoring", true)
	$AnimationPlayer.play("idle")
	completed_animation = true
	blocking = false
	crouching = false
	attacking = false
	match character_name:
		"Kelsie":
			$Hair.visible = false
		"John":
			$Bullets.emitting = false
		"Terje":
			$BrochureSpill.emitting = false
		"Tyler":
			$BeesTravel.visible = false
			$BeesTravel.emitting = false

func getting_shot():
	attacking = false
	
	if bot:
		fighting = false
		completed_animation = false
		emit_signal("bot_damage_taken")
		
	$AnimationPlayer.play("getting shot")

func collapse():
	if $NegaSmoke.is_playing():
		$NegaSmoke.visible = false

	$AnimationPlayer.play("collapse")

func stunned():
	$SpecialCooldown.visible = false
	$CooldownTimer.stop()
	$AnimationPlayer.play("stunned")

func squish():
	$AnimationPlayer.play("squish")
	if $NegaSmoke.is_playing():
		$NegaSmoke.visible = false
	play_sound("res://sounds/characters/Kelsie/boot-stomp.wav", false)

func skeletonize():
	$AnimationPlayer.play("skeletonize")

func _TERJE_skeletonize_sound():
	play_sound("res://sounds/characters/Terje/skeletonize.wav", false)

func victory():
	$AnimationPlayer.play("victory")

func set_name(name:String):
	character_name = name
	
func set_bot(isBot:bool):
	bot = isBot
	
	if bot:
		var _1 = connect("bot_damage_taken", self, "bot_damage_taken")
		if name == "player2":
			scale.x = -1

func _process(_delta):
	if $SpecialCooldown.visible:
		$SpecialCooldown.value = $CooldownTimer.time_left

func _physics_process(_delta):
	if bot == false:
		velocity = Vector2()
		velocity.y += gravity
		get_input()
		
		if tyler_walking_away:
			velocity.x -= MOVE_SPEED
				
		var _unused = move_and_slide(velocity, Vector2.UP)

func get_input():
	if bot or not fighting:
		return
	
	if Input.is_action_just_released("quit"):
		fight_controller.pause_game()
	elif blocking and Input.is_action_just_released("block"):
		$AnimationPlayer.play("block-release")
	elif blocking and upside_down and Input.is_action_just_released("special"):
		$AnimationPlayer.play("block-release")
	elif crouching:
		if upside_down:
			if Input.is_action_pressed("kick"):
				$AnimationPlayer.play('uppercut')
			elif Input.is_action_just_released("ui_up"):
				$AnimationPlayer.play("crouch-return")
		else:
			if Input.is_action_pressed("punch"):
				$AnimationPlayer.play('uppercut')
			elif Input.is_action_just_released("crouch"):
				$AnimationPlayer.play("crouch-return")
	elif not busy():
		if Input.is_action_pressed("punch"):
			if enemy_is_close():
				if upside_down:
					$AnimationPlayer.play("kick-close")
				else:
					$AnimationPlayer.play("punch-close")
			else:
				if upside_down:
					$AnimationPlayer.play("kick-far")
				else:
					$AnimationPlayer.play("punch-far")
		elif Input.is_action_pressed("kick"):
			if enemy_is_close():
				if upside_down:
					$AnimationPlayer.play("punch-close")
				else:
					$AnimationPlayer.play("kick-close")
			else:
				if upside_down:
					$AnimationPlayer.play("punch-far")
				else:
					$AnimationPlayer.play("kick-far")
		elif Input.is_action_pressed("block"):
			if upside_down:
				$AnimationPlayer.play("special")
			else:
				$AnimationPlayer.play("block")
		elif Input.is_action_pressed("crouch") and upside_down == false:
			$AnimationPlayer.play("crouch")
		elif Input.is_action_pressed("ui_up") and upside_down == true:
			$AnimationPlayer.play("crouch")
		elif Input.is_action_pressed("special"):
			if upside_down:
				$AnimationPlayer.play("block")
			else:
				$AnimationPlayer.play("special")
		elif Input.is_action_pressed("ui_left"):
			if upside_down:
				if facing == "left":
					$AnimationPlayer.play("walk-backward")
				else:
					$AnimationPlayer.play("walk-forward")
				
				if enemy.character_name == "F.U.G.U.M.":
					velocity.x -= (MOVE_SPEED * .5)
				else:
					velocity.x += MOVE_SPEED
			else:
				if facing == "left":
					$AnimationPlayer.play("walk-forward")
				else:
					$AnimationPlayer.play("walk-backward")
				
				if enemy.character_name == "F.U.G.U.M.":
					velocity.x -= (MOVE_SPEED * .5)
				else:
					velocity.x -= MOVE_SPEED
		elif Input.is_action_pressed("ui_right"):
			if upside_down:
				if facing == "right":
					$AnimationPlayer.play("walk-backward")
				else:
					$AnimationPlayer.play("walk-facing")
				if enemy.character_name == "F.U.G.U.M.":
					velocity.x += (MOVE_SPEED * .5)
				else:
					velocity.x -= MOVE_SPEED
			else:
				if facing == "right":
					$AnimationPlayer.play("walk-forward")
				else:
					$AnimationPlayer.play("walk-backward")
				if enemy.character_name == "F.U.G.U.M.":
					velocity.x += (MOVE_SPEED * .5)
				else:
					velocity.x += MOVE_SPEED
		elif can_use_fatality and Input.is_action_pressed("fatality"):
			var distance = abs(global_position.x - enemy.global_position.x)
			match character_name:
				"Kelsie":
					# can't be too close
					if distance < 200:
						return
				"Terje":
					# can't be too close
					if distance < 300:
						return
				"Tyler":
					# must be within arms reach
					if distance > 120 or distance < 80:
						return
			fatality()
		else:
			idle()
			velocity.x = 0

func _on_AnimationPlayer_animation_started(anim_name):
	if character_name == "Kelsie" and anim_name != "special":
		$Hair.visible = false
	elif character_name == "John" and anim_name != "special":
		$Bullets.emitting = false
	elif character_name == "Terje" and anim_name != "special":
		$BrochureSpill.emitting = false
	elif character_name == "Tyler" and anim_name != "special":
		$BeesTravel.visible = false
		$BeesTravel.emitting = false
		$Bees.playing = false
	
	match anim_name:
		"bees":
			attacking = false
			fighting = false
			completed_animation = false
		"getting shot":
			attacking = false
			fighting = false
			completed_animation = false
		"punch-far","punch-close","kick-far","kick-close":
			attacking = true
			play_sound("res://sounds/characters/effects/attack.wav", true)
		"block":
			blocking = true
		"block-release":
			blocking = false
		"crouch":
			crouching = true
		"crouch-release","uppercut":
			crouching = false
			if anim_name == "uppercut":
				attacking = true
				play_sound("res://sounds/characters/effects/attack.wav", true)
		"blade-gut-hit":
			if character_name == "Kelsie":
				$Hair.visible = false
			elif character_name == "Terje":
				$BrochureSpill.emitting = false
			elif character_name == "John":
				$Bullets.emitting = false
			$SpecialCooldown.visible = false
			play_sound("res://sounds/characters/effects/blade-gut-hit.wav", true)
		"hit-face","hit-uppercut":
			if enemy.character_name != "Kelsie" or enemy.get_node("AnimationPlayer").current_animation != "special":
				play_sound("res://sounds/characters/effects/punched.wav", true)
			$BloodSquirt.emitting = true
			if anim_name == "hit-uppercut":
				completed_animation = false
				$SpecialCooldown.visible = false
				# disable enemy's attack so we don't get uppercut chained
				enemy.get_node("AttackCircle").set_deferred("monitoring", false)
		"hit-gut":
			play_sound("res://sounds/characters/effects/kicked.wav", true)
		"fatality":
			$SpecialCooldown.visible = false
		"fatality-start":
			$SpecialCooldown.visible = false
		"collapse":
			$SpecialCooldown.visible = false
		"stunned":
			$SpecialCooldown.visible = false
		"special":
			if character_name == "Kelsie":
				if _KELSIE_is_dizzy:
					attacking = true
					completed_animation = false
					$AnimationPlayer.play("dizzy")
					return
			elif character_name == "John":
				if _JOHN_guns_jammed:
					attacking = true
					completed_animation = false
					$AnimationPlayer.play("special jammed")
					return
				else:
					$Bullets.lifetime = abs(enemy.global_position.x - global_position.x) / 180
					$Bullets.emitting = true
					enemy.getting_shot()
					$SoundPlayer.stream = load("res://sounds/characters/John/shot.wav")
					$SoundPlayer.play()
			elif character_name == "Terje":
				if _TERJE_brochures_spilt:
					attacking = true
					completed_animation = false
					$AnimationPlayer.play("special flubbed")
					return
			elif character_name == "Tyler":
				if _TYLER_bees_tired:
					attacking = true
					completed_animation = false
					$BeeSwarm.emitting = true
					$Bees.playing = true
					$AnimationPlayer.play("bees")
					return
			
			attacking = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if attacking:
		attacking = false
		
	match anim_name:
		"block":
			if blocking:
				$AnimationPlayer.play("blocking")
		"block-release":
			blocking = false
			idle()
		"crouch":
			crouching = true
			$AnimationPlayer.play("crouching")
		"crouch-return":
			crouching = false
			idle()
		"hit-uppercut","knock-back":
			completed_animation = true
			if will_collapse:
				$AnimationPlayer.stop()
			else:
				$AnimationPlayer.play("get-up")
		"collapse":
			play_sound("res://sounds/characters/effects/drop.wav", true)
			$AnimationPlayer.stop()
		"squish":
			$SpecialCooldown.visible = false
			$AnimationPlayer.stop()
		"skeletonize":
			$SpecialCooldown.visible = false
			$AnimationPlayer.stop()
		"fatality-start":
			if enemy.character_name != "John":
				$AnimationPlayer.play("fatality-repeat")
			else:
				$AnimationPlayer.play("fatality-end-john")
		"fatality-end-john":
			_TYLER_walk_away()
		"response-john":
			if character_name != "John":
				get_parent().fatality_modulate("out")
				collapse()
		"tossed-by-oxanna":
			$SpecialCooldown.visible = false
			if health > 10:
				$AnimationPlayer.play("get-up")
		"hit-blade":
			fighting = false
		"get-up":
			if not bot and $CooldownTimer.time_left > 0:
				$SpecialCooldown.visible = true
			if $NegaSmoke.is_playing():
				$NegaSmoke.visible = true

			fighting = true
			completed_animation = true
			enemy.get_node("AttackCircle").set_deferred("monitoring", true)
			idle()
		"victory":
			$SpecialCooldown.visible = false
			$AnimationPlayer.stop()
		"special":
			match character_name:
				"Kelsie":
					_KELSIE_is_dizzy = true
				"John":
					_JOHN_guns_jammed = true
				"Terje":
					_TERJE_brochures_spilt = true
				"Tyler":
					_TYLER_bees_tired = true
			special_cooldown_timer()
			idle()
		"getting shot":
			$AnimationPlayer.play("get-up")
		"fatality-end":
			$AnimationPlayer.stop()
		"dizzy":
			completed_animation = true
			idle()
		"bees":
			completed_animation = true
			fighting = true
			idle()
		"tyler-fatality-start":
			fighting = false
			if character_name != "John":
				$AnimationPlayer.play("tyler-fatality-loop")
			else:
				$AnimationPlayer.play("tyler-fatality-end")
				# remove the left wall so Tyler can pass
				get_parent().get_node("WallLeft").queue_free()
				# and flip John's head (?)
				$Head.scale.x = -1
		"tyler-fatality-end":
			$AnimationPlayer.stop()
		_:
			idle()
		

func _on_AttackCircle_body_entered(_body):
#	if free_animations.has($AnimationPlayer.current_animation):
#		# don't want to freeze if we walk into each other
#		return
	if z_index <= enemy.z_index:
		z_index = 1
		enemy.z_index = 0
	enemy.damage_taken($AnimationPlayer.current_animation)

func landing_damage():
	health -= 10
	emit_signal("update_health", self, health)

func damage_taken(animation:String):
	attacking = false
	crouching = false
	if character_name == "Tyler":
		$BeesTravel.visible = false
		$BeesTravel.emitting = false
	$BeeSwarm.emitting = false

	completed_animation = true
	
	if character_name == "Kelsie":
		$Hair.visible = false
	elif character_name == "John":
		$Bullets.emitting = false
		if $AnimationPlayer.current_animation == "special":
			enemy.idle()
	elif character_name == "Terje":
		$BrochureSpill.emitting = false
	
	if bot:
		emit_signal("bot_damage_taken")
	
	# this needs to be further down to only play if damage won't kill player	
#	if completed_animation == false:
#		return

	if $AnimationPlayer.current_animation == "stunned":
		$AnimationPlayer.play("collapse")
		get_parent().match_over(enemy)
	elif blocking and enemy.character_name != "Ox Anna":
		play_sound("res://sounds/characters/effects/block.wav", true)
		$AnimationPlayer.play("block-release")
		health -= 2
		if health <= 0:
			damage_taken("punch-far")
	else:
		$AnimationPlayer.stop()

		match animation:
			"punch-far", "punch-close", "kick-far":
				$AnimationPlayer.play("hit-face")
				if animation == "kick-far":
					health -= DAMAGE_MEDIUM
				else:
					health -= DAMAGE_LOW
			"kick-close":
				$AnimationPlayer.play("hit-gut")
				health -= DAMAGE_LOW
			"uppercut":
				$AnimationPlayer.play("hit-uppercut")
				health -= DAMAGE_HIGH
				if $NegaSmoke.is_playing():
					$NegaSmoke.visible = false
				if health <= 0:
					will_collapse = true
			"throw":
				$AnimationPlayer.play("thrown")
			"special":
				match enemy.character_name:
					# John's is done in take_bullet()
					"Kelsie":
						play_sound("res://sounds/characters/Kelsie/special-crack.wav", true)
						health -= 20
						$AnimationPlayer.play("hit-face")
					"Terje":
						var brochure_node = enemy.get_node_or_null("brouchure")
						if brochure_node:
							brochure_node.queue_free()
						completed_animation = false
						health -= 20
						$AnimationPlayer.play("knock-back")
			"tossed-by-oxanna":
				blocking = false
				crouching = false
				$AnimationPlayer.play("tossed-by-oxanna")
				health -= 40
			_:
				idle()

	emit_signal("update_health", self, health)
	
func enemy_is_close():
	var distance = abs(enemy.global_position.x - global_position.x)
	return distance < 130
	
func tween(to:Vector2, rot, time:float):
	var tween = get_node("Tween")
	if scale.y < 0:
		to.x *= -1
	tween.interpolate_property(self, "position",
			position, Vector2(clamp(position.x + to.x, 80, 980), position.y + to.y), time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if rot != 0:
		if scale.y < 0:
			rot *= -1
		tween.interpolate_property(self, "rotation_degrees",
			rotation_degrees, rotation_degrees + rot, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				
	tween.start()

func play_sound(soundPath:String, variate:bool):
	$SoundPlayer.stream = load(soundPath)
	if variate:
		$SoundPlayer.pitch_scale = rand_range(0.8, 1.2)
	else:
		$SoundPlayer.pitch_scale = 1
	$SoundPlayer.play()

func take_bullet():
	health -= 5
	emit_signal("update_health", self, health)

func swarm_bees():
	emit_signal("bot_damage_taken")
	$AnimationPlayer.play("bees")
	$Bees.playing = true
	$BeeSwarm.emitting = true

func being_slapped():
	# set fightscene's fatality timer long
	if character_name != "John":
		var timer = Timer.new()
		timer.wait_time = 7
		timer.one_shot = true
		timer.connect("timeout", self, "_on_Tyler_FatalityTimer_timeout")
		add_child(timer)
		timer.start()
		$SoundPlayer.stream = load("res://sounds/characters/Tyler/slap.wav")
	
	$AnimationPlayer.play("tyler-fatality-start")

func _on_Tyler_FatalityTimer_timeout():
	get_parent().fatality_modulate("out")
	var whichLine = randi() % 3 + 1
	get_parent().announcer_speak("tyler-fatality-%s" % whichLine)
	var end_fight_timer = get_parent().get_node("EndFightTimer")
	end_fight_timer.wait_time = 7
	end_fight_timer.start()

func slap():
	$SoundPlayer.pitch_scale = rand_range(0.9, 1.1)
	$SoundPlayer.play()

func busy():
	return free_animations.has($AnimationPlayer.current_animation) == false

func fatality():
	get_parent().fatality_modulate("in")
	game_controller.fatalityHorn()
	game_controller.fight_music_fade("out")
	
	fighting = false
	get_parent().get_node("FatalityTimer").stop()
	match character_name:
		"John":
			_JOHN_fatality_start()
		"Kelsie":
			_KELSIE_fatality()
		"Terje":
			_TERJE_fatality()
		"Tyler":
			_TYLER_fatality()

func special_cooldown_timer():
	$SpecialCooldown.value = 5.0
	if not bot:
		$SpecialCooldown.visible = true
	$CooldownTimer.start()

func _on_CooldownTimer_timeout():
	$SpecialCooldown.visible = false
	_TERJE_brochures_spilt = false
	_KELSIE_is_dizzy = false
	_JOHN_guns_jammed = false
	_TYLER_bees_tired = false

################################
# CHARACTER-SPECIFIC FUNCTIONS #
################################

# JOHN	
func _JOHN_gun_jammed_click():
	$SoundPlayer.stream = load("res://sounds/click.wav")
	$SoundPlayer.play()

func _JOHN_fatality_start():
	$AnimationPlayer.play("fatality-start")
	var random = RandomNumberGenerator.new()
	random.randomize()
	var punNum = random.randi_range(1, 6)
	$FatalityPlayer.stream = load("res://characters/John/sounds/punality%s.wav" % punNum)
	$FatalityPlayer.play()

func _JOHN_fatality_end():
	if enemy.character_name != "John":
		enemy.get_node("AnimationPlayer").play("response-john")
		get_parent().format_text_for_label("punality")
		get_parent().announcer_speak("punality")
	else:
		# delay a bit for comedic effect!
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		timer.connect("timeout", enemy, "_JOHN_punality")
		add_child(timer)
		timer.start()
		
	get_parent().get_node("EndFightTimer").start()
	$AnimationPlayer.play("fatality-end")

func _JOHN_punality():
	set_process(false)
	get_parent().fatality_modulate("out")
	$AnimationPlayer.play("response-john")
	get_parent().announcer_speak("sigh")

func _on_FatalityPlayer_finished():
	_JOHN_fatality_end()

func skeletonized():
	$AnimationPlayer.play("skeletonize")

# KELSIE
func _KELSIE_fatality():
	$AnimationPlayer.play("fatality")
	z_index = 1000

func _KELSIE_position_boot():
	$Boot.global_position.x = enemy.global_position.x + ($Boot.texture.get_width() * .25)
	$Boot.global_position.y = $Boot.texture.get_height() / -2

func _KELSIE_drop_boot():
	$Boot.visible = true
	var tween = get_node("Tween")
	tween.interpolate_property($Boot, "position",
		$Boot.position, Vector2($Boot.position.x, -80), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	enemy.squish()
	tween.start()

func _KELSIE_raise_boot():
	get_parent().fatality_modulate("out")
	get_parent().format_text_for_label("such bootality!")
	get_parent().announcer_speak("fatality")
	var tween = get_node("Tween")
	tween.interpolate_property($Boot, "position",
		$Boot.position, Vector2($Boot.position.x, -1500), 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()
	victory()
	get_parent().get_node("EndFightTimer").start()

func fatality_response_john():
	$AnimationPlayer.play("response-john")

func one_squirt():
	var blood = enemy.get_node("BloodSquirt")
	blood.emitting = true

# TERJE
func _TERJE_throwBrochures():
	var brochure = Area2D.new()
	brochure.name = "brochure"
	var collisionShape = CollisionShape2D.new()
	collisionShape.shape = RectangleShape2D.new()
	brochure.add_child(collisionShape)
	brochure.collision_layer = enemy.collision_mask
	brochure.connect("body_entered", self, "_on_AttackCircle_body_entered")
	
	var sprite = Sprite.new()
	sprite.texture = preload("res://characters/Terje/sprites/others/brochure.png")
	sprite.rotation_degrees = 90
	sprite.scale = Vector2(1.2, 1.2)
	brochure.add_child(sprite)
	
	var sprite2 = sprite.duplicate()
	sprite2.position = Vector2(-40, -40)
	brochure.add_child(sprite2)
	
	add_child(brochure)
	brochure.position = Vector2(230, 60)
	var tween = get_node("Tween")
	tween.interpolate_property(brochure, "position",
			brochure.position, Vector2(2000, brochure.position.y), 0.9,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _TERJE_fatality():
	$AnimationPlayer.play("fatality")

func _TERJE_play_brochureClone():
	$BrochuresParticlesBig/BrochureClone.play()

func _TERJE_throwCyclone():
	var tween = get_node("Tween")
	var from = Vector2(global_position.x, $BrochuresParticlesBig.global_position.y)
	var to = enemy.global_position

	tween.interpolate_property($BrochuresParticlesBig, "global_position",
			from, to,  0.5,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _TERJE_enemy_play_skeletonize_sound():
	enemy._TERJE_skeletonize_sound()
	get_parent().format_text_for_label("fatality")
	get_parent().announcer_speak("fatality")

func _TERJE_skeletonize_enemy():
	enemy.skeletonize()
	victory()
	get_parent().get_node("EndFightTimer").start()
	get_parent().fatality_modulate("out")

func _TYLER_bee_travel_time():
	# calculate bee travel time from BeesTravel particles
	# setting lifetime to distance between Tyler and opponent
	# and dividing by gravity.x
	var lifetime = abs(enemy.global_position.x - global_position.x) / 750
	$BeesTravel.lifetime = lifetime
	$BeesTravel.visible = true

func _TYLER_bee_swarm():
	enemy.swarm_bees()

func _TYLER_fatality():
	# make sure opponent's body obscures hand
	if z_index >= enemy.z_index:
		z_index = 0
		enemy.z_index = 1
	$AnimationPlayer.play("fatality-start")

func _TYLER_walk_away():
	get_parent().fatality_modulate("out")
	fighting = false
	$SoundPlayer.stream = load("res://sounds/characters/Tyler/whistling.wav")
	$SoundPlayer.play()
	scale.x = -scale.x
	$AnimationPlayer.play("walk-forward")
	tyler_walking_away = true
	get_parent().get_node("EndFightTimer").wait_time = 6
	get_parent().get_node("EndFightTimer").start()
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1
	timer.connect("timeout", self, "announcer_clean_up")
	add_child(timer)
	timer.start()

func announcer_clean_up():
	get_parent().announcer_speak("tyler-clean-up")
	
func _TYLER_enemy_slapping():
	enemy.being_slapped()
