extends Node2D

# this scene gets loaded after CharacterSelectScene
# and stays active the entire StoryMode game 
# loads first conversation scene, fades in
# from there, loads fight scene, fades out the conversation scene and removes it
# and then fades in the fight scene
# and the reverse

var player
var opponent
var opponents = ["John", "Kelsie", "Terje"]
var bosses = ["Ox Anna", "FUGUM"]
var fight_number
var conversation_scene
var fight_scene

func set_player(playerName:String):
	# called by CharacterSelectScene
	player = playerName

func _ready():
	fight_number = 0
	randomize()
	shuffle_opponent_order()
	get_opponent()
	load_conversation()

func shuffle_opponent_order():
	opponents.erase(player) # remove player
	opponents.shuffle() # shuffle remaining characters
	opponents.append(player) # add player's self-doubt
	opponents.append_array(bosses) # add the bosses at the end

func get_opponent():
	opponent = opponents[fight_number]

func load_conversation():
	conversation_scene = load("res://scenes/ConversationScene.tscn").instance()
	# pass the scene number
	conversation_scene.fight_number = fight_number
	$ConversationScene.add_child(conversation_scene)
	$AnimationPlayer.play("fade in conversation")

func load_fight():
	fight_scene = load("res://scene/Level.tscn")
	# jovi need to pass the player and opponent first
	$FightScene.add_child(fight_scene)
	$AnimationPlayer.play("fade in fight")

func remove_conversation_scene():
	if $ConversationScene.has_node("ConversationScene"):
		var node = get_node("ConversationScene/ConversationScene")
		$ConversationScene.remove_child(node)

func remove_fight_scene():
	if $FightScene.has_node("Environment"):
		var node = get_node("FightScene/Environment")
		$FightScene.remove_child(node)

func conversation_done():
	# called by ConversationScene when done
	$AnimationPlayer.play("fade out conversation")

func fight_done():
	# called by FightSCene when done
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
			$AnimationPlayer.play("fade in fight")
		"fade in fight": # after fight scene is visible
			# start fight
			$FightScene/FightScene.start_fight()
		"fade out fight": # after fight scene is invisible
			# remove the scene
			remove_fight_scene()
			# start next convo/fight
			next_fight()

func next_fight():
	fight_number += 1
	
	if fight_number <= opponents.size():
		load_conversation()
	else:
		# StoryMode complete; re-add the launch screen
		var launch_screen = load("res://scenes/LaunchScreen.tscn").instance()
		get_tree().get_root().add_child(launch_screen)
		# then remove self
		get_tree().get_root().remove_child(self)
