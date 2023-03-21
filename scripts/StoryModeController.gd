extends Node2D

# this scene gets loaded after CharacterSelectScene
# and stays active the entire StoryMode game 
# loads first conversation scene, fades in
# from there, loads fight scene, fades out the conversation scene and removes it
# and then fades in the fight scene
# and the reverse

var player
var opponent
var player_characters = ["John", "Kelsie", "Terje", "Tyler"]
var opponents = player_characters.duplicate()
var bosses = ["Ox_Anna", "FUGUM"]
var fight_number
var conversation_scene
var fight_scene
var current_background
var backgrounds
var random
var game_controller

func set_game_controller(controller):
	game_controller = controller

func set_player(playerName:String):
	player = playerName

func prepare_story():
	fight_number = 0
	random = RandomNumberGenerator.new()
	random.randomize()
	randomize()
	shuffle_opponent_order()
	load_conversation()

func shuffle_opponent_order():
	opponents.erase(player) # remove player
	player_characters.erase(player)
	opponents.shuffle() # shuffle remaining characters
	opponents.append(player) # add player's self-doubt
	opponents.append_array(bosses) # add the bosses at the end

func pick_background():
	if opponent == "FUGUM":
		current_background = "rooftop-nighttime"
		return
	
	backgrounds = shuffle_backgrounds()
	current_background = backgrounds[fight_number]

func shuffle_backgrounds():
	backgrounds = ['arrivals', 'breakroom', 'courtyard', 'humanHistory', 'lobby', 'office', 'parking', 'roundhouse', 'shop']
	backgrounds.shuffle()
	while backgrounds[0] == "office":
		backgrounds.shuffle()
	
	return backgrounds

func get_opponent():
	opponent = opponents[fight_number]

func load_conversation():
	if game_controller.menu_music_playing():
		game_controller.menu_music_fade("out")
	elif game_controller.fight_music_playing():
		game_controller.fight_music_fade("out")
	
	game_controller.play_storymode_music()
	conversation_scene = preload("res://scenes/ConversationScene.tscn").instance()
	$ConversationScene.add_child(conversation_scene)
	conversation_scene.set_fight_number(fight_number)
	conversation_scene.set_player(player)
	get_opponent()
	conversation_scene.set_game_controller(game_controller)
	conversation_scene.set_storymode_controller(self)
	conversation_scene.set_opponent(opponent)
	pick_background()
	conversation_scene.set_background(current_background)
	if current_background == "office":
		current_background = "officeSpace"
	$AnimationPlayer.play("fade in conversation")

func load_fight():
	if opponent == "Ox_Anna":
		fight_scene = preload("res://scenes/BossFight-Ox_Anna.tscn").instance()
	elif opponent == "FUGUM":
		fight_scene = preload("res://scenes/BossFight-FUGUM.tscn").instance()
		fight_scene.set_corpses(player_characters)
		game_controller.fight_music_fade("out")
		game_controller.ambience_fade("out")
	else:
		fight_scene = preload("res://scenes/FightScene.tscn").instance()
	
	$FightScene.add_child(fight_scene)
	fight_scene.set_player1(player)
	fight_scene.set_player2(opponent)
	fight_scene.set_match_type("storymode")
	fight_scene.set_game_controller(game_controller)
	fight_scene.set_storymode_controller(self)
	fight_scene.set_background(current_background)
	fight_scene.set_scene()
	$AnimationPlayer.play("fade in fight")

func remove_conversation_scene():
	if $ConversationScene.has_node("ConversationScene"):
		var node = $ConversationScene.get_node("ConversationScene")
		$ConversationScene.remove_child(node)
		node.queue_free()
		
func remove_fight_scene():
	var node
	if $FightScene.has_node("FightScene"):
		node = $FightScene.get_node("FightScene")
	elif $FightScene.has_node("BossFight-Ox_Anna"):
		node = $FightScene.get_node("BossFight-Ox_Anna")
	elif $FightScene.has_node("BossFight-FUGUM"):
		node = $FightScene.get_node("BossFight-FUGUM")
		
	$FightScene.remove_child(node)
	node.queue_free()

func conversation_done():
	# called by ConversationScene when done
	$AnimationPlayer.play("fade out conversation")

func fight_done():
	# called by FightScene when done
	$AnimationPlayer.play("fade out fight")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade in conversation": # after conversation scene is visible
			# start conversation
			$ConversationScene/ConversationScene.start_conversation()
		"fade out conversation": # after conversation scene is invisible
			# remove the scene
			remove_conversation_scene()
			load_fight()
		"fade in fight": # after fight scene is visible
			# start fight
			pass #?
		"fade out fight": # after fight scene is invisible
			# remove the scene
			remove_fight_scene()
			# start next convo/fight
			next_opponent()

func next_opponent():
	fight_number += 1
	
	if fight_number <= opponents.size():
		load_conversation()
	else:
		# StoryMode complete; re-add the launch screen
		game_controller.load_launch_screen()
