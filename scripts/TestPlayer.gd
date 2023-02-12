extends KinematicBody2D

const GRAVITY = 1000
const MOVE_SPEED = 300

const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 20

var fighting = false
var blocking = false
var crouching = false
var attacking = false # for bot
var can_use_fatality = false

var bot
signal bot_damage_taken
signal bot_resume_timer
signal bot_stop_timer
signal update_health(health)
var enemy

var velocity
var free_animations = ["walk-backward","walk-forward","idle"] # list of animations that can be interrupted
var blockable = ["punch-far","kick-far","special"]

var character_name
var health

func _ready():
	var _unused = connect("update_health", get_parent(), "update_health")

func set_health(h:int):
	health = h

func idle():
	$AnimationPlayer.play("idle")

func collapse():
	$AnimationPlayer.play("collapse")

func stunned():
	$AnimationPlayer.play("stunned")

func victory():
	$AnimationPlayer.play("victory")

func set_name(name:String):
	character_name = name
	
func set_bot(isBot:bool):
	bot = isBot
	
	if bot:
		var _unused = connect("bot_damage_taken", self, "bot_damage_taken")
		_unused = connect("bot_resume_timer", self, "bot_resume_timer")
		_unused = connect("bot_stop_timer", self, "bot_stop_timer")
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
			$AnimationPlayer.play("crouch-release")
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
			$AnimationPlayer.play("walk-backward")
			velocity.x -= MOVE_SPEED
		elif Input.is_action_pressed("ui_right"):
			$AnimationPlayer.play("walk-forward")
			velocity.x += MOVE_SPEED
		elif can_use_fatality and Input.is_action_pressed("fatality"):
			fatality()
		else:
			$AnimationPlayer.play("idle")
			velocity.x = 0

func _on_AnimationPlayer_animation_started(anim_name):
	if free_animations.has(anim_name):
		return
	
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
		"hit-face", "hit-uppercut":
			play_sound("res://sounds/characters/effects/punched.wav", true)
		"hit-gut":
			play_sound("res://sounds/characters/effects/kicked.wav", true)
		"stagger":
			if bot:
				emit_signal("bot_damage_taken")

func _on_AnimationPlayer_animation_finished(anim_name):
	attacking = false
	
	match anim_name:
		"block":
			$AnimationPlayer.play("blocking")
		"crouch":
			$AnimationPlayer.play("crouching")
		"hit-uppercut":
			$AnimationPlayer.play("get-up")
		"collapse":
			play_sound("res://sounds/characters/effects/drop.wav", true)
		"knock-back":
			$AnimationPlayer.play("get-up")
		"get-up","hit-face","hit-gut":
			$AnimationPlayer.play("idle")
		"fatality-start":
			$AnimationPlayer.play("fatality-repeat")
		"victory", "fatality-end":
			set_process(false)
		"response-john":
			if character_name != "John":
				collapse()
		_:
			$AnimationPlayer.play("idle")
	
	if bot:
		emit_signal("bot_resume_timer")

func _on_AttackCircle_body_entered(_body):
#	if free_animations.has($AnimationPlayer.current_animation):
#		# don't want to freeze if we walk into each other
#		return
	if z_index <= enemy.z_index:
		z_index = 1
		enemy.z_index = 0
	enemy.damage_taken($AnimationPlayer.current_animation)

func damage_taken(animation:String):
	# emit might get picked up by both bots!
	if bot:
		emit_signal("bot_damage_taken")

	if $AnimationPlayer.current_animation == "stunned":
		$AnimationPlayer.play("collapse")
		get_parent().match_over(enemy)
	elif blocking:
		play_sound("res://sounds/characters/effects/block.wav", true)
		$AnimationPlayer.play("block-release")
		if bot:
			emit_signal("bot_resume_timer")
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
		$AnimationPlayer.play("knock-back")

func busy():
	return free_animations.has($AnimationPlayer.current_animation) == false

func fatality():
	fighting = false
	get_parent().get_node("FatalityTimer").stop()
	match character_name:
		"John":
			_JOHN_fatality_start()

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
		get_parent().announcer_speak("sigh")
		
	get_parent().get_node("EndFightTimer").start()
	$AnimationPlayer.play("fatality-end")

func _JOHN_punality():
	set_process(false)
	$AnimationPlayer.play("response-john")

func _on_FatalityPlayer_finished():
	_JOHN_fatality_end()
