extends KinematicBody2D

const GRAVITY = 1000
var WALK_SPEED = 300
const DAMAGE_LOW = 10
const DAMAGE_MEDIUM = 15
const DAMAGE_HIGH = 20
const JUMP_FORCE = 8000

var animTree
var bot = false
var busy = false
var facing
var isCrouching = false
var isBlocking = false
var isStunned = false
var attack
var health
var enemy
var character_name # actual name, no Nega

var character_select_screen

var match_over = true
var can_use_fatality = false

var velocity

func _ready():
	character_select_screen = load("res://scenes/CharacterSelectScreen.tscn")
	
	$AnimationTree.active = true
	animTree = $AnimationTree.get("parameters/playback")
	health = 100

func getInput():
	if match_over:
		return
		
	if Input.is_action_pressed("quit"):
		match_over = true
		animTree.travel("idle")
		enemy.match_over = true
		enemy.animTree.travel("victory")
		get_parent().close_out_game()
#		var levelScene = get_tree().get_root().get_node("Environment")
#		get_tree().get_root().remove_child(levelScene)
	
	if isBlocking and Input.is_action_just_released("block"):
		block_release()
	elif isCrouching:
		if Input.is_action_just_pressed("punch"):
			uppercut()
		if Input.is_action_just_released("crouch"):
			crouch_return()
	elif not busy:
		if Input.is_action_pressed("punch"):
#			if (scale.y > 0 and Input.is_action_pressed("left")) or (scale.y < 0 and Input.is_action_pressed("right")):
#				throw()
#			else:
			punch()
		elif Input.is_action_pressed("kick"):
			kick()
		elif Input.is_action_pressed("block"):
			block()
		elif Input.is_action_pressed("special"):
			special()
		elif Input.is_action_pressed("crouch"):
			crouch()
		elif enemy.isStunned and can_use_fatality and Input.is_action_pressed("fatality"):
			fatality()
		elif Input.is_action_pressed("right"):
#			if Input.is_action_pressed("jump"):
#				velocity.x += WALK_SPEED
#				velocity.y -= JUMP_FORCE
#				somersault("right")
#			else:
			move("right")
		elif Input.is_action_pressed("left"):
#			if Input.is_action_pressed("jump"):
#				velocity.x += -WALK_SPEED
#				velocity.y -= JUMP_FORCE
#				somersault("left")
#			else:
			move("left")
		else:
			idle()

func fatality():
	pass

func squish():
	animTree.travel("squish")
	# also cancel our own timer so we don't re-collapse
	if get_node_or_null("Timer"):
		$Timer.queue_free()

func skeletonize_sound():
	$SoundPlayer.stream = load("res://sounds/characters/Terje/skeletonize.wav")
	$SoundPlayer.play()

func skeletonize():
	if get_node_or_null("Timer"):
		$Timer.queue_free()
	animTree.travel("skeletonize")

func _physics_process(_delta:float):
	velocity = Vector2.ZERO
	getInput()
	
	velocity.y += GRAVITY
	var _result = move_and_slide(velocity, Vector2.UP)

func idle():
	animTree.travel("idle")

func move(direction:String):
	if direction == "right":
		if scale.y > 0:
			animTree.travel("walk-forward")
		else:
			animTree.travel("walk-backward")
			
		velocity.x += WALK_SPEED
	elif direction == "left":
		if scale.y > 0:
			animTree.travel("walk-backward")
		else:
			animTree.travel("walk-forward")
		
		velocity.x -= WALK_SPEED

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
	
func block():
	animTree.travel("block")

func block_release():
	animTree.travel("block-release")

func punch():
	if abs(position.x - enemy.position.x) < 140:
		animTree.travel("punch-close")
	else:
		animTree.travel("punch-far")

func throw():
	if abs(position.x - enemy.position.x) < 120:
		animTree.travel("throw")

func somersault(direction):
	if facing == direction:
		animTree.travel("somersault-forward")
	else:
		animTree.travel("somersault-backward")

func crouch():
	animTree.travel("crouch")

func crouch_return():
	animTree.travel("crouch-return")

func uppercut():
	animTree.travel("uppercut")

func kick():
	if abs(position.x - enemy.position.x) < 140:
		animTree.travel("kick-close")
	else:
		animTree.travel("kick-far")

func special():
	animTree.travel("special")

func setBusy(isBusy:bool):
	busy = isBusy

func setCrouching(crouching:bool):
	isCrouching = crouching

func setBlocking(blocking:bool):
	isBlocking = blocking

func setStunned(stunned:bool):
	isStunned = stunned
	if bot:
		$ActionTimer.stop()
	animTree.travel("stunned")

func setAttack(atk:String):
	attack = atk

func collapse():
	get_parent().match_over(self, false)
	animTree.travel("collapse")

func victory():
	animTree.travel("victory")

func landingDamage():
	get_parent().damageTaken(self, 15)

func _on_HitBox_area_entered(area):
	if isBlocking:
		get_parent().damageTaken(self, 5)
		setBusy(true)
		animTree.travel("block-release")
	else:

		var atk = enemy.attack
		
		# cancel current animation
		$AnimationPlayer.stop(true)
		$AnimationTree.active = false
		$AnimationTree.active = true
		var damage = 0
		
		if atk != null:
			# disable AttackCircle
			$AttackCircle/CollisionShape2D.disabled = true
			busy = true
			match atk:
				"punch-far", "kick-far", "punch-close":
					animTree.travel("hit-face")
					$BloodSquirt.emitting = true
					damage = DAMAGE_LOW
				"kick-close":
					animTree.travel("hit-gut")
					damage = DAMAGE_LOW
				"uppercut":
					animTree.travel("hit-uppercut")
					$BloodSquirt.emitting = true
					damage = DAMAGE_HIGH
				"throw":
					animTree.travel("thrown")
				"special":
					setBusy(true)
					animTree.travel("knock-back")
					damage = DAMAGE_LOW
					if area.name == "brochure":
						enemy.get_node("brochure").queue_free()
				"charge":
					setBusy(true)
					enemy.animTree.travel("gore")
					animTree.travel("tossed-by-oxanna") # change to hard toss
					damage = 34
					
			get_parent().damageTaken(self, damage)

func play_sound(sound:String):
	$SoundPlayer.stream = load(sound)
	$SoundPlayer.play()

func notify_match_over():
	get_parent().match_over(self, true)
