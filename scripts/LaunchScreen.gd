extends Node2D

onready var allow_input = false
var game_mode
var game_controller

# selection(s) hold the options to select from menu and their positions
var selection = 0
var selections = [
	[Vector2(328, 288), Vector2(692, 288)],
	[Vector2(328, 352), Vector2(692, 352)],
	[Vector2(320, 417), Vector2(700, 417)],
	[Vector2(400, 529), Vector2(620, 529)],
]

func set_game_controller(controller):
	game_controller = controller

func _ready():
	game_controller.scene_ready("LaunchScreen")

func start(intro_shown:bool):
	$AnimationPlayer.play("fadeIn")
	#not working yet
	if intro_shown:
		$AnimationPlayer.seek(7.1)

func _input(event):
	if allow_input == false:
		return

	if event.is_action_pressed("ui_accept"):
		do_selection()
	elif event.is_action_released("ui_down"):
		move_skulls(1)
	elif event.is_action_released("ui_up"):
		move_skulls(-1)
	elif event.is_action_released("quit"):
		$AnimationPlayer.play("quit")

func set_allow_input():
	allow_input = true

func move_skulls(direction:int):
	$DemoTimer.start()
	selection = selection + direction
	if selection == selections.size():
		selection = 0
	elif selection < 0:
		selection = selections.size()-1
	
	$MammothLeft.position = selections[selection][0]
	$MammothRight.position = selections[selection][1]
	
	$Click.play()

func do_selection():
	if selection == 2:
		$Announcer.stream = load("res://sounds/announcer/TBD.wav")
		$Announcer.play()
		return
		
	
	match selection:
		3:
			$AnimationPlayer.play("quit")
			return
		0:
			game_mode = "storymode"
		1:
			game_mode = "deathmatch"
		2:
			game_mode = "multiplayer"
			
	game_controller.get_node("Boom").play()
	$AnimationPlayer.play("fadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fadeIn":
			game_controller.flag_intro_shown()
		"quit":
			game_controller.quit_game()
		"fadeOut":
			game_controller.set_game_mode(game_mode)

func _on_DemoTimer_timeout():
	game_mode = "ai_vs_ai"
	$AnimationPlayer.play("fadeOut")
