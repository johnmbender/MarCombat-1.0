extends KinematicBody2D

const GRAVITY = 1000
const MOVE_SPEED = 300

const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 20

var facing
var fighting = false
var blocking = false
var crouching = false
var being_gored = false
var attacking = false # for bot
var can_use_fatality = false

var bot
signal bot_damage_taken
signal bot_next_action
signal bot_stop_timer
signal update_health(health)
var enemy

# CHARACTER-SPECIFIC VARIABLES
var _KELSIE_is_dizzy = false
var _KELSIE_special_spam = 3
var _KELSIE_dizzy_timer
var _KELSIE_special_reset_timer

var velocity
var free_animations = ["walk-backward","walk-forward","idle","crouch","crouching","crounch-return"] # list of animations that can be interrupted
var blockable = ["punch-far","kick-far","special"]

var character_name
var health

func _ready():
	var _1 = connect("update_health", get_parent(), "update_health")

func set_health(h:int):
	health = h

func idle():
	$AnimationPlayer.play("idle")

func collapse():
	$AnimationPlayer.play("collapse")

func stunned():
	$AnimationPlayer.play("stunned")

func squish():
	$AnimationPlayer.play("squish")
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
		var _2 = connect("bot_next_action", self, "bot_next_action")
		var _3 = connect("bot_stop_timer", self, "bot_stop_timer")
		if name == "player2":
			scale.x = -1

func _physics_process(_delta):
	if bot == false:
		velocity = Vector2()
		velocity.y += GRAVITY
		get_input()
		var _unused = move_and_slide(velocity, Vector2.UP)

func get_input():
	if not fighting:
		return
	
	if blocking and Input.is_action_just_released("block"):
		$AnimationPlayer.play("block-release")
	elif crouching:
		if Input.is_action_pressed("punch"):
			$AnimationPlayer.play('uppercut')
		elif Input.is_action_just_released("crouch"):
			$AnimationPlayer.play("crouch-return")
	elif not busy():
		if Input.is_action_pressed("punch"):
			if enemy_is_close():
				# taking this out because PITA
	#				if (Input.is_action_pressed("ui_left") and enemy.scale.y < 0) or (Input.is_action_pressed("ui_right") and enemy.scale.y > 0):
	#					$AnimationPlayer.play("throw")
	#				else:
				$AnimationPlayer.play("punch-close")
			else:
				$AnimationPlayer.play("punch-far")
		elif Input.is_action_pressed("kick"):
			if enemy_is_close():
				$AnimationPlayer.play("kick-close")
			else:
				$AnimationPlayer.play("kick-far")
		elif Input.is_action_pressed("block"):
			$AnimationPlayer.play("block")
		elif Input.is_action_pressed("crouch"):
			$AnimationPlayer.play("crouch")
		elif Input.is_action_pressed("special"):
			$AnimationPlayer.play("special")
		elif Input.is_action_pressed("ui_left"):
			if facing == "left":
				$AnimationPlayer.play("walk-forward")
			else:
				$AnimationPlayer.play("walk-backward")
			velocity.x -= MOVE_SPEED
		elif Input.is_action_pressed("ui_right"):
			if facing == "right":
				$AnimationPlayer.play("walk-forward")
			else:
				$AnimationPlayer.play("walk-backward")
			velocity.x += MOVE_SPEED
		elif can_use_fatality and Input.is_action_pressed("fatality"):
			fatality()
		else:
			$AnimationPlayer.play("idle")
			velocity.x = 0

func _on_AnimationPlayer_animation_started(anim_name):
#	if free_animations.has(anim_name):
#		return
	
	if bot:
		emit_signal("bot_stop_timer")
	
	match anim_name:
		"block":
			blocking = true
		"block-release":
			blocking = false
		"crouch":
			crouching = true
		"crouch-release","uppercut":
			crouching = false
		"blade-gut-hit":
			play_sound("res://sounds/characters/effects/blade-gut-hit.wav", false)
		"hit-face","hit-uppercut":
			play_sound("res://sounds/characters/effects/punched.wav", true)
		"hit-gut":
			play_sound("res://sounds/characters/effects/kicked.wav", true)
		"stagger":
			if bot:
				emit_signal("bot_damage_taken")
		"special":
			if character_name == "Kelsie":
				if _KELSIE_special_spam == 3:
					_KELSIE_start_special_reset_timer()
					
				_KELSIE_special_spam -= 1
				
				if _KELSIE_special_spam == 0:
					_KELSIE_dizzy()
					play_sound("res://sounds/characters/Kelsie/dizzy.wav", false)
				else:
					play_sound("res://sounds/characters/Kelsie/special.wav", false)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"block":
			if blocking:
				$AnimationPlayer.play("blocking")
			return
		"block-release":
			blocking = false
			$AnimationPlayer.play("idle")
		"crouch":
			crouching = true
			$AnimationPlayer.play("crouching")
			return
		"crouch-return":
			crouching = false
			$AnimationPlayer.play("idle")
		"hit-uppercut","knock-back":
			$AnimationPlayer.play("get-up")
			return
		"collapse":
			play_sound("res://sounds/characters/effects/drop.wav", true)
			$AnimationPlayer.stop()
			return
		"squish":
			$AnimationPlayer.stop()
			return
		"skeletonize":
			$AnimationPlayer.stop()
			return
		"fatality-start":
			$AnimationPlayer.play("fatality-repeat")
			return
		"victory", "fatality-end":
			set_process(false)
			return
		"response-john":
			if character_name != "John":
				collapse()
			return
		"tossed-by-oxanna":
			if health > 10:
				$AnimationPlayer.play("get-up")
			return
		_:
			$AnimationPlayer.play("idle")
	
	if bot and fighting:
		emit_signal("bot_next_action")
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
#	if not free_animations.has($AnimationPlayer.current_animation):
#		return
	
	attacking = false
	crouching = false
	
	# emit might get picked up by both bots!
	if bot:
		emit_signal("bot_damage_taken")

	if $AnimationPlayer.current_animation == "stunned":
		$AnimationPlayer.play("collapse")
		get_parent().match_over(enemy)
	elif blocking and enemy.character_name != "Ox Anna":
		play_sound("res://sounds/characters/effects/block.wav", true)
		$AnimationPlayer.play("block-release")
		if bot:
			emit_signal("bot_next_action")
		health -= 5
	else:
		$AnimationPlayer.stop()

		match animation:
			"punch-far", "punch-close", "kick-far":
				$AnimationPlayer.play("hit-face")
				health -= DAMAGE_LOW
			"kick-close":
				$AnimationPlayer.play("hit-gut")
				health -= DAMAGE_LOW
			"uppercut":
				$AnimationPlayer.play("hit-uppercut")
				health -= DAMAGE_HIGH
			"throw":
				$AnimationPlayer.play("thrown")
			"special":
				match enemy.character_name:
					# John's is calculated in getting_shot
					"Kelsie":
						health -= DAMAGE_LOW
						$AnimationPlayer.play("hit-face")
					"Terje":
						health -= DAMAGE_LOW
						$AnimationPlayer.play("knock-back")
			"tossed-by-oxanna":
				blocking = false
				crouching = false
				$AnimationPlayer.play("tossed-by-oxanna")
				health -= 40
			_:
				$AnimationPlayer.play("idle")

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

func is_getting_shot(currently:bool):
	if currently:
		$AnimationPlayer.play("stagger")
		if bot:
			emit_signal("bot_stop_timer")
	else:
		$AnimationPlayer.play("idle")

func bullet_damage():
	health -= 2
	emit_signal("update_health", self, health)

func busy():
	return free_animations.has($AnimationPlayer.current_animation) == false

func fatality():
	get_parent().modulate = Color(0.7, 0.4, 0.4, 1.0)
	get_tree().get_root().get_node("GameController").fatalityHorn()
	get_tree().get_root().get_node("GameController").fight_to_conversation()
	
	fighting = false
	get_parent().get_node("FatalityTimer").stop()
	match character_name:
		"John":
			_JOHN_fatality_start()
		"Kelsie":
			_KELSIE_fatality()
		"Terje":
			_TERJE_fatality()

################################
# CHARACTER-SPECIFIC FUNCTIONS #
################################

# JOHN
func _JOHN_shoot_bullets(shoot):
	$Bullets.emitting = shoot
	enemy.is_getting_shot(shoot)
	
	if shoot:
		$SoundPlayer.stream = load("res://sounds/characters/John/shot.wav")
		$SoundPlayer.play()
		$Bullets.lifetime = abs(enemy.global_position.x - global_position.x) / 180

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
	$AnimationPlayer.play("response-john")
	get_parent().announcer_speak("sigh")

func _on_FatalityPlayer_finished():
	_JOHN_fatality_end()


# KELSIE
func _KELSIE_start_special_reset_timer():
	_KELSIE_special_reset_timer = Timer.new()
	_KELSIE_special_reset_timer.wait_time = 3
	_KELSIE_special_reset_timer.one_shot = true
	_KELSIE_special_reset_timer.connect("timeout", self, "_KELSIE_reset_special_spam")
	add_child(_KELSIE_special_reset_timer)
	_KELSIE_special_reset_timer.start()

func _KELSIE_dizzy():
	_KELSIE_is_dizzy = true
	if _KELSIE_special_reset_timer:
		_KELSIE_special_reset_timer = null

	$AnimationPlayer.play("stunned")
	_KELSIE_dizzy_timer = Timer.new()
	_KELSIE_dizzy_timer.wait_time = 3
	_KELSIE_dizzy_timer.one_shot = true
	_KELSIE_dizzy_timer.connect("timeout", self, "_KELSIE_undizzy")
	add_child(_KELSIE_dizzy_timer)
	_KELSIE_dizzy_timer.start()

func _KELSIE_undizzy():
	_KELSIE_is_dizzy = false
	if _KELSIE_dizzy_timer:
		_KELSIE_dizzy_timer = null

	_KELSIE_reset_special_spam()
	idle()

func _KELSIE_reset_special_spam():
	if _KELSIE_special_reset_timer != null:
		_KELSIE_special_reset_timer = null
	_KELSIE_special_spam = 3

func _KELSIE_fatality():
	$AnimationPlayer.play("fatality")
	# cancel the parent timer to prevent collapse
#	get_parent().get_node("EndFightTimer").stop()
	
	# place Kelsie highest so boot is over victim
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
	print("p1 is at ", position.x)
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
