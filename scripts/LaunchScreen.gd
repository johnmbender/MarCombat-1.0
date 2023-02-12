extends Node2D

onready var allow_input = false
var game_mode

# selection(s) hold the options to select from menu and their positions
var selection = 0
var selections = [
	[Vector2(328, 288), Vector2(692, 288)],
	[Vector2(328, 352), Vector2(692, 352)],
	[Vector2(296, 417), Vector2(724, 417)],
	[Vector2(400, 529), Vector2(620, 529)],
]

func _ready():
	get_parent().scene_ready("LaunchScreen")

func start():
	$AnimationPlayer.play("fadeIn")
	
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
		get_tree().quit()

func allow_input():
	allow_input = true

func move_skulls(direction:int):
	selection = selection + direction
	if selection == selections.size():
		selection = 0
	elif selection < 0:
		selection = selections.size()-1
	
	$MammothLeft.position = selections[selection][0]
	$MammothRight.position = selections[selection][1]
	
	$Click.play()

func do_selection():
	$Boom.play()
	
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
			
	$AnimationPlayer.play("fadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"quit":
			get_parent().quit_game()
		"fadeOut":
			get_parent().set_game_mode(game_mode)

func _on_DemoTimer_timeout():
	game_mode = "ai_vs_ai"
	$AnimationPlayer.play("fadeOut")
