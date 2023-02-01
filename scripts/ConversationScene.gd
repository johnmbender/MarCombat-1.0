extends Node2D

var player
var pronoun
var player_scene
var opponent
var opponent_scene
var scene_number
var greyed = Color(0.55, 0.55, 0.55, 1.0)
var narrator_dialogue
var narrator_line_number

# called by the singleton
# provided a scene number, to determine which animation to play
# provided the player name, pronoun, and the opponent AI name

func _ready():
	# FOR TESTING, FOR NOW
	player = "Kelsie"
	pronoun = "She"
	opponent = "Terje"
	
	$VSplitContainer/DialogBox.visible = false
	$VSplitContainer/DialogBox/Dialogue.percent_visible = 0
	
	player_scene = load("res://characters/%s/%s-conversation.tscn" % [player, player]).instance()
	opponent_scene = load("res://characters/%s/%s-Conversation.tscn" % [opponent, opponent]).instance()
	
	player_scene.flip_h = true
	
	$VSplitContainer/HSplitContainer.add_child(player_scene)
	player_scene.visible = false
	$VSplitContainer/HSplitContainer.add_child(opponent_scene)
	opponent_scene.visible = false

	narrator_dialogue = {
		0: [
			"%s has a lightbulb moment one day.\n\n%s comes up with the best idea ever.\n\nThe idea would skyrocket the prestige of the museum, make it highly profitable, and spike morale, risk-free and at nearly zero cost.\n\n%s wants to run it past a coworker before running it up the line..." % [player, pronoun, pronoun],
			"%s explains the idea to %s, who cheerfully provides a lot of constructive feedback..." % [pronoun, opponent],
		]
	}

	# FOR NOW
	scene_number = 0
	narrator_line_number = 0
	$AnimationPlayer.play("scene %s" % scene_number)
	
	
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("scene %s" % scene_number)
			$Blinker.stop(true)

func advance_narrator_line():
	narrator_line_number += 1

func set_narrator():
	$Narrator.text = narrator_dialogue[scene_number][narrator_line_number]

func pause():
	$AnimationPlayer.stop()

func set_character_visible(character:String, visible:bool):
	get_node("$VSplitContainer/HSplitContainer/%s" % character).visible = visible

func play_blink(which:String):
	$Blinker.play(which)
