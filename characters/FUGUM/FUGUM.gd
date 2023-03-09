extends KinematicBody2D

var spinnerTree
var timingTree
var isStunned = false
var busy = false
var isCrouching = false
var isBlocking = false
var enemy
var character_name = "F.U.G.U.M."
var match_over = true
var enemy_pierced = false
var random = RandomNumberGenerator.new()
var positive_lines = [1,2,3,4]
var negative_lines = [1,2,3,4,5,6]
var pierce_chance = 0
var attack

func _ready():
	spinnerTree = $Wheel/Spinner/SpinnerTree.get("parameters/TimeScale/scale")
	timingTree = $Wheel/Timing/TimingTree.get("parameters/playback")
	$Swinger.play("forward")

func idle():
	$SoundBlender.play("idle")

func is_getting_shot(_unused):
	pass

func release():
	# one-time plays the release sound, when stopping or starting
	$Release.play()

func start_blade():
	# one-time activate right here
	$Wheel/Spinner/SpinnerTree.active = true
	$Wheel/Spinner.play("spin")
	$Swinger.play("first stop")
	timingTree.travel("start")

func stop_blade():
	enemy_pierced = false
	timingTree.travel("stop")

func stop():
	$Tween.stop_all()

func voice(type:String):
	if $Wheel/Voice.playing:
		$Wheel/Voice.stop()
		
	random.randomize()
	var num = 0
	var stream
	if type == "positive":
		if positive_lines.size() == 0:
			positive_lines = [1,2,3,4]
		num = random.randi_range(0, positive_lines.size()-1)
		stream = "res://characters/FUGUM/sounds/voice/positive/positive%s.ogg" % positive_lines[num]
		positive_lines.remove(num)
	else:
		if negative_lines.size() == 0:
			negative_lines = [1,2,3,4,5,6]
		num = random.randi_range(0, negative_lines.size()-1)
		stream = "res://characters/FUGUM/sounds/voice/negative/negative%s.ogg" % negative_lines[num]
		negative_lines.remove(num)
		
	$Wheel/Voice.stream = load(stream)
	$Wheel/Voice.play()

func move(toward_player:bool):
	$SoundBlender.play("moving")
	
	var start = position
	var end
	
	if toward_player:
		set_collisions(true, false)
		voice("negative")
		end = Vector2(700, position.y)
		timingTree.travel("start")
		$Swinger.play("forward")
	else:
		set_collisions(false, true)
		voice("positive")
		end = Vector2(1000, position.y)
		$Swinger.play("backward")
		
	$Tween.interpolate_property(self, "position",
			start, end, 5.0,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func leave():
	$SoundBlender.play("leave")
	$Swinger.play("backward")

func set_collisions(monitoring:bool, disabled:bool):
	$Wheel/AtRot0.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot0/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot45.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot45/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot90.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot90/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot135.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot135/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot180.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot180/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot225.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot225/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot270.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot270/CollisionShape2D.set_deferred("disabled", disabled)
	$Wheel/AtRot315.set_deferred("monitoriing", monitoring)
	$Wheel/AtRot315/CollisionShape2D.set_deferred("disabled", disabled)

func notify_player_pierced(area:String):
	if enemy_pierced == false:
		get_parent().player_pierced(area)
		enemy_pierced = true
		set_collisions(false, true)


func _on_Tween_tween_all_completed():
	# done moving, notify level
	get_parent().allow_input = true
	$Swinger.play("stop")

func _on_AtRot0_body_entered(_body):
	notify_player_pierced("AtRot0")

func _on_AtRot45_body_entered(_body):
	notify_player_pierced("AtRot45")

func _on_AtRot90_body_entered(_body):
	notify_player_pierced("AtRot90")

func _on_AtRot135_body_entered(_body):
	notify_player_pierced("AtRot135")

func _on_AtRot180_body_entered(_body):
	notify_player_pierced("AtRot180")

func _on_AtRot225_body_entered(_body):
	notify_player_pierced("AtRot225")

func _on_AtRot270_body_entered(_body):
	notify_player_pierced("AtRot270")

func _on_AtRot315_body_entered(_body):
	notify_player_pierced("AtRot315")

func _on_Swinger_animation_finished(anim_name):
	match anim_name:
		"stop", "first stop":
			$Swinger.play("idle")






