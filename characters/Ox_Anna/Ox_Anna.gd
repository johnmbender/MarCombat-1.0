extends KinematicBody2D

const GRAVITY = 1000
const RUN_SPEED = 400

var speed_modifier = 1.1
var animTree
var isCharging = false
var knockedDown = false
var facing
var character_name = "Ox Anna"
var health
var enemy
var match_over
var isStunned
var destination
var attack

func _ready():
	$AnimationTree.active = true
	animTree = $AnimationTree.get("parameters/playback")
	turn()

func _physics_process(delta):
	var velocity = Vector2()
	
	# gravity
	velocity.y += GRAVITY
	
	if destination != null && isCharging:
		if facing == "left" && position.x <= destination.x:
			knockedDown = false
			isCharging = false
			attack = null
			if $AnimationPlayer.current_animation == "knockdown":
				animTree.travel("get-up")
			else:
				$TurnTimer.start()
		elif facing == "right" && position.x >= destination.x:
			knockedDown = false
			isCharging = false
			attack = null
			if $AnimationPlayer.current_animation == "knockdown":
				animTree.travel("get-up")
			else:
				$TurnTimer.start()
		elif facing == "left":
			velocity.x -= RUN_SPEED * speed_modifier
		elif facing == "right":
			velocity.x += RUN_SPEED * speed_modifier
			
	var _result = move_and_slide(velocity, Vector2.UP)

func charge():
	isCharging = true
	destination = Vector2()
	attack = "charge"
	
	if $Sprite.flip_h:
		destination = Vector2(100, position.y)
	else:
		destination = Vector2(900, position.y)
	
	animTree.travel("run")
	
func turn():
	animTree.travel("idle")
	$AttackCircle.monitorable = true
	$AttackCircle/CollisionShape2D.disabled = false
	set_knocked_down(false)
	$ChargeTimer.start()
	$Sprite.flip_h = !$Sprite.flip_h
	$AttackCircle/CollisionShape2D.position.x = -$AttackCircle/CollisionShape2D.position.x
	animTree.travel("idle")
	if facing == "left":
		facing = "right"
	else:
		facing = "left"

func _on_ChargeTimer_timeout():
	charge()

func _on_AttackCircle_area_entered(area):
	speed_modifier += 0.2

	if enemy.attack == "uppercut" && enemy.get_node("AttackCircle").monitorable == true && enemy.get_node("AttackCircle/CollisionShape2D").disabled == false:
		play_sound("punch")
		$AnimationPlayer.stop(true)
		$AttackCircle.monitorable = false
		$AttackCircle/CollisionShape2D.disabled = true
		animTree.travel("knockdown")
		health -= 20
		get_parent().get_node("UI").set_player_health(2, health)

func set_knocked_down(kd:bool):
	knockedDown = kd

func play_sound(sound:String):
	if sound == "moo":
		var random = RandomNumberGenerator.new()
		random.randomize()
		var moo = random.randi_range(1, 4)
		sound = "Ox_Anna/moo_%s.wav" % moo
	else:
		sound = "effects/%s.wav" % sound
		
	$SoundPlayer.stream = load("res://sounds/characters/%s" % sound)
	$SoundPlayer.play()

func _on_TurnTimer_timeout():
	turn()

func victory():
	animTree.travel("idle")
