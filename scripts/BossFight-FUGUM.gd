extends Node2D

var attack_scale
var blade_caught
var attack = "blade"
var area_attached_to
var let_go = false
var let_go_min = 220
var let_go_max = 250
var retirement_years
var allow_input
var fight_over = false
var selected_gift = 1
var player_name
var player

var game_controller
var storymode_controller

func _ready():
	blade_caught = false
	area_attached_to = null
	retirement_years = 29

func set_game_controller(controller):
	game_controller = controller

func set_storymode_controller(controller):
	storymode_controller = controller

func set_scene():
	var scenePath = "res://characters/%s/%s.tscn" % [player_name, player_name]
	player = load(scenePath).instance()
	player.name = "player"
	player.set_bot(false)
	player.global_position = Vector2(100,350)
	$Player.add_child(player)
	player.health = 100
	player.idle()
	$AnimationPlayer.play("intro")
	$UI/Player1/HBoxContainer/Name.text = player_name
	$UI/Player2/HBoxContainer/Name.text = "F.U.G.U.M."
	player.set_z_index(10)
	$Player/player/AttackCircle.set_deferred("monitorable", false)
	$Player/player/AttackCircle/CollisionShape2D.set_deferred("disabled", true)
	$Player/player.set_deferred("montoring", false)
	$Player/player.set_deferred("monitorable", true)
	$Player/player.collision_layer = 1
	$FUGUM.enemy = player
	player.enemy = $FUGUM

func set_player1(name:String):
	player_name = name

func set_player2(_n):
	pass

func set_background(_b):
	pass

func set_match_type(_mt):
	pass

func _unhandled_key_input(event):
	if allow_input:
		if fight_over == false:
			player.get_node("AnimationPlayer").play("get-up")
			player.fighting = true
			if retirement_years > 0:
				$UI.set_player_health(1, 100)
				$FUGUM.enemy.health = 100
				$FUGUM.move(true)
				allow_input = false
		else:
			if event.is_action_released("ui_right"):
				selected_gift += 1
			elif event.is_action_released("ui_left"):
				selected_gift -= 1
			elif event.is_action_pressed("ui_accept"):
				present_gift()
			
			if selected_gift < 1:
				selected_gift = 3
			elif selected_gift > 3:
				selected_gift = 1
			
			update_gift_modulations()

func update_gift_modulations():
	for n in range(1,4):
		var gift = $GiftContainer.get_node("Gift%s" % n)
		if n == selected_gift:
			gift.modulate = Color(1,1,1,1)
		else:
			gift.modulate = Color(0,0,0,1)

func _process(_delta):
	if not fight_over:
		if blade_caught:
			player.global_position = $FUGUM/Wheel.get_node(area_attached_to).global_position
			var modifier = 0
			match area_attached_to:
				'AtRot90':
					modifier = 90
				'AtRot180':
					modifier = 180
				'AtRot270':
					modifier = 270
			player.rotation_degrees = $FUGUM/Wheel.rotation_degrees + modifier
			var adjusted_rot = int(player.rotation_degrees) % 360
			if adjusted_rot < 0:
				adjusted_rot += 360
				
			if let_go and adjusted_rot > let_go_min and adjusted_rot < let_go_max:
				let_go = false
				blade_caught = false
				area_attached_to = null
				$FUGUM.stop_blade()
				player.rotation_degrees = 0
				player.get_node("AnimationPlayer").play("hit-blade")
				$Player/player/BloodSquirt.emitting = false
				if retirement_years <= 0:
					$RetirementTimer.stop()
					fight_over = true
					$AnimationPlayer.play("outro")
				else:
					$RetirementTimer.start()

func start_fight():
	$FUGUM.move(true)
	$RetirementTimer.start()
	player.fighting = true

func clear_label():
	$HBoxContainer/Label.visible = false
	$HBoxContainer/Label.text = ""

func format_text_for_label(text:String):
	clear_label()
	var width = text.length() * 55
	$HBoxContainer/Label.rect_min_size.x = width
	$HBoxContainer/Label.text = text.to_upper()
	$HBoxContainer/Label.visible = true

func moving():
	$FUGUM/SoundBlender.play("moving")

func start_blade():
	$FUGUM.start_blade()

func player_pierced(area:String):
	$UI.set_player_health(1, 0)
	player.get_node("AnimationPlayer").stop()
	$FUGUM.stop()
	$RetirementTimer.paused = true
	player.fighting = false
	blade_caught = true
	area_attached_to = area
	move_camera(true)
	$AnimationPlayer.play("zoom")

func move_camera(to_player:bool):
	var tween = get_node("Tween")
	var start = $Camera2D.position
	var end
	var player_position = player.global_position
	var time
	
	if to_player:
		end = Vector2(player_position.x, player_position.y-100)
		time = 0.1
	else:
		end = Vector2(512, 300)
		time = 0.1
		
	tween.interpolate_property($Camera2D, "position",
			start, end, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func slow_time():
	Engine.time_scale = 0.01
	player.get_node("AnimationPlayer").play("blade-gut-hit")

func resume_time():
	move_camera(false)
	Engine.time_scale = 1.0
	$RetirementTimer.paused = false
	$Camera2D.position = Vector2(512, 300)
	var random = RandomNumberGenerator.new()
	random.randomize()
	$BladeReleaseTimer.wait_time = random.randf_range(2.0, 5.0)
	$BladeReleaseTimer.start()
	$FUGUM.move(false)

func _on_Lightning_timeout():
	var random = RandomNumberGenerator.new()
	random.randomize()
	var strike = random.randi_range(1,3)
	$Lightning.play("strike%s" % strike)
	var wait_time = random.randf_range(0.7, 8)
	$LightningTimer.wait_time = wait_time
	$LightningTimer.start()

func stop_lightning():
	$LightningTimer.stop()

func _on_BladeReleaseTimer_timeout():
	let_go = true

func _on_RetirementTimer_timeout():
	$YearsToRetirement/Label.text = "Years to retirement: %s" % retirement_years
	
	if retirement_years <= 0:
		$RetirementTimer.stop()
		if blade_caught and let_go == false:
			let_go = true
		elif blade_caught == false:
			$FUGUM.stop_blade()
			$AnimationPlayer.play("outro")
			player.fighting = false
			fight_over = true
	else:
		retirement_years -= 1

func say_player_name():
	$Announcer.stream = load("res://characters/FUGUM/sounds/voice/retire/%s.wav" % player_name)
	$Announcer.play()

func show_gifts():
	var gifts = ["billyBass","fannyPack","fibreFlower","gaudyNecklace","nepotismArt", "nickelback"]
	var random = RandomNumberGenerator.new()
	random.randomize()
	for i in range(1, 4):
		var rand = random.randi_range(0, gifts.size()-1)
		$GiftContainer.get_node("Gift%s" % i).texture = load("res://characters/FUGUM/sprites/gifts/%s.png" % gifts[rand])
		gifts.remove(rand)
	$GiftContainer.visible = true
	$GiftContainer.modulate = Color(1,1,1,1)
	
#	remove_child($FUGUM)
	$FUGUM.queue_free()

func present_gift():
	var gift
	for i in range(1, 4):
		if i != selected_gift:
			$GiftContainer.get_node("Gift%s" % i).visible = false
		else:
			gift = $GiftContainer.get_node("Gift%s" %i)
	
	$Retirement/Label.visible = false
#	$ChosenGift.texture = gift.texture
	
#	$ChosenGiftText.text = gift_text
#	$ChosenGift.visible = true
#	$ChosenGiftText.visible = true
	
	$AnimationPlayer.play("fade everything")

func return_to_launch():
	game_controller.load_launch_screen()

func match_over(_t1, _t2):
	# ignoring
	pass
