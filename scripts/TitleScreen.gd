extends Node2D

var backgrounds = []
onready var background1 = $CanvasLayer/TextureRect1
onready var background2 = $CanvasLayer/TextureRect2
var menu_buttons = []
var selected_button

func _ready():
	# disallow input until the menu is ready
	set_process_input(false)
	
	# get the menu buttons
	var children = $CanvasLayer/CenterContainer/VBoxContainer.get_children()
	for child in children:
		if ["DeathMatchButton","ControlsButton","QuitButton"].has(child.name):
			menu_buttons.append(child)
	
	# get all level backgrounds
	load_backgrounds()
	
	# start rotation
	_on_BackgroundRotateTimer_timeout()


func _input(event):
	if event.is_action_released("p1_crouch") and selected_button < (menu_buttons.size() - 1):
		selected_button += 1
	elif event.is_action_released("p1_jump") and selected_button > 0:
		selected_button -= 1
	elif event.is_action_released("p1_punch"):
		if selected_button == 0:
			# deathmatch
			GameState.game_mode = "DeathMatch"
			GameState.character1_player = "player1"
			GameState.character2_player = "AI"
			
			# change to Location Selection scene
			get_tree().change_scene("res://Scenes/DeathmatchCharacterSelect.tscn")
		elif selected_button == 0:
			GameState.game_mode = "Controls"
			GameState.character1_player = "player1"
			GameState.character2_player = "AI"
			
			# change to Controls scene
			get_tree().change_scene("res://Scenes/Controls.tscn")
		elif selected_button == 2:
			get_tree().quit()
	
	highlight_button(menu_buttons[selected_button])

func highlight_button(button):
	button.grab_focus()

	# restart idle timer
	$IdleTimer.start()


func load_backgrounds():
	var directory = Directory.new()
	var path = "res://Assets/Backgrounds"
	if directory.open(path) == OK:
		directory.list_dir_begin(true, true)
		var image_name = directory.get_next()
		
		while image_name != "":
			if image_name.find(".import") == -1 and not directory.current_is_dir():
				var file_path = "res://Assets/Backgrounds/" + image_name
				var image_resource = load(file_path)
				backgrounds.append(image_resource)
				
			image_name = directory.get_next()
		
		randomize()
		backgrounds.shuffle()
	else:
		print("An error occurred accessing the backgrounds path!")


func _on_IdleTimer_timeout():
	GameState.roll_demo()


func _on_Button_pressed():
	pass


func _on_DeathMatchButton_pressed():
	GameState.game_mode = "DeathMatch"
	if get_tree().change_scene("res://Scenes/DeathmatchCharacterSelect.tscn"):
		print("DeathmatchCharacterSelect scene loaded")

func _on_ControlsButton_pressed():
	print("ok!")

func _on_StoryModeButton_pressed():
	GameState.game_mode = "StoryMode"
	print("well, MAKE Story Mode!")


func _on_QuitButton_pressed():
	print("quit?")
	get_tree().quit()


func _on_BackgroundRotateTimer_timeout():
	var next_background = backgrounds.pop_front()
	backgrounds.push_back(next_background)
	
	if $CanvasLayer/TextureRect1.modulate.a == 1:
		# 1 is showing so make 2 visible and fade out 1
		background1.get_node("AnimationPlayer").play("hide")
		background2.texture = next_background
		background2.get_node("AnimationPlayer").play("show")
	else:
		# 2 is showing so make 1 visible and fade out 2
		background2.get_node("AnimationPlayer").play("hide")
		background1.texture = next_background
		background1.get_node("AnimationPlayer").play("show")


func show_menu():
	$AnimationPlayer.play("showMenu")
	yield(get_tree().create_timer(1), "timeout")
	$MarCombat.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "showMenu":
		# focus the Deathmatch button
		selected_button = 0
		highlight_button(menu_buttons[0])
		set_process_input(true)
