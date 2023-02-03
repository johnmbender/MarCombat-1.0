extends AnimatedSprite

var dialogue

func _ready():
	dialogue = {
		"opponent": {
			"scene": {
				3: {
					"lines": {
						5: {
							"line": "Sure, %s! Whatcha got?",
							"action": "smile"
						},
						7: {
							"line": "What does that say on my coffee? Does that say Ox Anna?!",
							"action": "shocked"
						},
						9: {
							"line": "Do you think this is funny? You want Ox Anna? I'll GIVE YOU Ox Anna!",
							"action": "angry"
						}
					}
				}
			}
		}
	}
