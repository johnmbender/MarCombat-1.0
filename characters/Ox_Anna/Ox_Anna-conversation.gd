extends AnimatedSprite

onready var info = {
	"name": "Oksana",
	"birthday": "single-digits January",
	"hometown": "????"
}
onready var pronouns = ["she", "her", "her"]
onready var dialogue = {
	"opponent": {
		"scene": {
			3: {
				"lines": {
					6: {
						"line": "Sure, %s! Whatcha got? Oh, is this coffee for me?  You're so sweet!	",
						"action": "smile"
					},
					8: {
						"line": "What does that say on my coffee? Are you freaking kidding me?",
						"action": "shocked"
					},
					10: {
						"line": "Do you think this is funny? You want Ox Anna? I'll GIVE YOU Ox Anna!",
						"action": "angry"
					},
				}
			}
		}
	}
}

func get_dialogue(role:String, scene:int):
	return dialogue[role]["scene"][scene]["lines"]

func get_pronouns():
	return pronouns
