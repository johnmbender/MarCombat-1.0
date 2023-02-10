extends KinematicBody2D

const GRAVITY = 1000
const MOVE_SPEED = 300

const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 20

var blocking = false
var crouching = false
var attacking = false # for bot

var bot
signal bot_damage_taken
signal bot_resume_action_timer
var enemy

var velocity
var free_animations = ["walk-backward","walk-forward","idle"] # list of animations that can be interrupted
var blockable = ["punch-far","kick-far","special"]

var character_name

func idle():
	$AnimationPlayer.play("idle")

func set_name(name:String):
	character_name = name
	
func set_bot(isBot:bool):
	bot = isBot
	
	if bot:
		scale.x = -1
		var _unused1 = connect("bot_damage_taken", self, "bot_damage_taken")
		var _unused2 = connect("bot_resume_action_timer", self, "bot_resume_action_timer")

func _physics_process(_delta):
	if bot == false:
		velocity = Vector2()
		velocity.y += GRAVITY
		get_input()
		var _unused = move_and_slide(velocity, Vector2.UP)

func get_input():
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
		else:
			$AnimationPlayer.play("idle")
			velocity.x = 0

func _on_AnimationPlayer_animation_started(anim_name):
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
			emit_signal("bot_resume_action_timer")
			$AnimationPlayer.play("idle")
		_:
			$AnimationPlayer.play("idle")

func _on_AttackCircle_body_entered(_body):
	if free_animations.has($AnimationPlayer.current_animation):
		# don't want to freeze if we walk into each other
		return
		
	if z_index <= enemy.z_index:
		z_index = 1
		enemy.z_index = 0
	enemy.damage_taken($AnimationPlayer.current_animation)

func damage_taken(animation:String):
	if bot:
		emit_signal("bot_damage_taken")
		
#	if not busy():
	if blocking:
		print("yeah blocking")
		play_sound("res://sounds/characters/effects/block.wav", true)
		$AnimationPlayer.play("block-release")
		emit_signal("bot_resume_action_timer")
	else:
		$AnimationPlayer.stop()
			
		match animation:
			"punch-far", "punch-close", "kick-far":
				$AnimationPlayer.play("hit-face")
			"kick-close":
				$AnimationPlayer.play("hit-gut")
			"uppercut":
				$AnimationPlayer.play("hit-uppercut")
			"throw":
				$AnimationPlayer.play("thrown")

func enemy_is_close():
	return abs(enemy.global_position.x - global_position.x) < 130
	
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
	else:
		$AnimationPlayer.play("knock-back")

func busy():
	return free_animations.has($AnimationPlayer.current_animation) == false

################################
# CHARACTER-SPECIFIC FUNCTIONS #
################################

# JOHN
func _JOHN_shoot_bullets(shoot):
	if shoot:
		$SoundPlayer.stream = load("res://sounds/characters/John/shot.wav")
		$SoundPlayer.play()
		$Bullets.lifetime = abs(enemy.global_position.x - global_position.x) / 180
		$Bullets.emitting = true
		
		enemy.is_getting_shot(true)
	else:
		$Bullets.emitting = false
		enemy.is_getting_shot(false)

func _JOHN_fatality_start():
	$AnimationPlayer.play("fatality-start")
	var random = RandomNumberGenerator.new()
	random.randomize()
	var punNum = random.randi_range(1, 6)
	$FatalityPlayer.stream = load("res://characters/John/sounds/punality%s.wav" % punNum)
	$FatalityPlayer.play()

func _JOHN_fatality_end():
	if enemy.character_name != "John":
		enemy.animTree.travel("response-john")
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 3.0
		timer.connect("timeout", self, "close_out_game")
		add_child(timer)
		timer.start()
		get_parent().format_text_for_label("punality")
		get_parent().announcer("punality")
	else:
		# delay a bit for comedic effect!
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		timer.connect("timeout", self, "punality")
		add_child(timer)
		timer.start()
		get_parent().format_text_for_label("friendship")
		
	$AnimationPlayer.play("fatality-end")

func _JOHN_punality():
	$AnimationPlayer.play("response-john")

func _on_FatalityPlayer_finished():
	_JOHN_fatality_end()
