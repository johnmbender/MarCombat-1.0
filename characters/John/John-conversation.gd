extends AnimatedSprite

onready var info = {
	"name": "John",
	"birthday": "May 2",
	"hometown": "Chicago, Illinois",
}
onready var pronouns = ["he", "him", "his"]
onready var dialogue = {
	"player": {
		"scene": {
			0: {
				"lines": {
					0: {
						"line": "Thanks for the help, %s!",
						"action": "normal",
					},
					2: {
						"line": "Thanks. Oksana's gonna love it..",
						"action": "smile",
					},
					4: {
						"line": "Um, what?",
						"action": "confused",
					},
					6: {
						"line": "No way in hell, %s, I worked hard on this!",
						"action": "angry",
					},
					8: {
						"line": null,
						"action": "fight"
					}
				},
			},
			1: {
				"lines": {
					0: {
						"line": "Seriously. What just happened? I need to find %s.",
						"action": "confused"
					},
					2: {
						"line": "You won't believe this.",
						"action": "no"
					},
					5: {
						"line": "Don't get me wrong. Helluva idea, but worth fighting someone for?",
						"action": "confused"
					},
					7: {
						"line": "lolwut?",
						"action": "shocked"
					},
					9: {
						"line": null,
						"action": "fight"
					}
				}
			},
			2: {
				"lines": {
					0: {
						"line": "This is just... wrong.",
						"action": "confused"
					},
					1: {
						"line": "There's no way this'll get off the ground.",
						"action": "no",
					},
					2: {
						"line": "I should have kept my mouth shut and my brain off.",
						"action" :"no"
					},
					3: {
						"line": "I'm such an idiot!",
						"action": "angry"
					},
					4: {
						"line": "What... is... happening?!",
						"action": "shocked"
					},
					6: {
						"line": null,
						"action": "fight"
					}
				}
			},
			3: {
				"lines": {
					0: {
						"line": "Ok ok ok ok. I feel better, strangely.",
						"action": "yes"
					},
					1: {
						"line": "Oksana will know what to do.",
						"action": "smile"
					},
					2: {
						"line": "I'll pick her up an Americano from Starbucks, she'll like that.",
						"action": "yes"
					},
					3: {
						"line": "That way she won't beat me up for my idea. Theoretically...",
						"action": "no"
					},
					4: {
						"line": "Hey Oksana. How goes? Have a moment?",
						"action": "smile"
					},
					6: {
						"line": "Wooo! I'm so happy to hear that, thanks.",
						"action": "smile"
					},
					8: {
						"line": "I know I joke around but I didn't write that. Funny though, right?",
						"action": "smile"
					},
					10: {
						"line": null,
						"action": "shocked"
					}
				}
			},
			4: {
				"lines": {
					0: {
						"line": "Screw this. I'm just going to send an email to someone up the chain.",
						"action": "yes"
					},
					1: {
						"line": "Huh... I'd swear they have an autoresponder.",
						"action": "smile"
					},
					3: {
						"line": "Okay, so, that was weird. Guess I'd better head down there and find out.",
						"action": "yes"
					},
				}
			}
		},
	},
	"opponent": {
		"scene": {
			0: {
				"lines": {
					1: {
						"line": "You're welcome! Cool idea, too, %s.",
						"action": "smile"
					},
					3: {
						"line": "Mind if I claim the idea as mine?",
						"action": "normal"
					},
					5: {
						"line": "Why so mad? I'll say you helped... a little.",
						"action": "confused"
					},
					7: {
						"line": "Do I really need to kick your ass, %s?",
						"action": "angry"
					},
					9: {
						"line": null,
						"action": "fight"
					}
				}
			},
			1: {
				"lines": {
					1: {
						"line": "You don't look so great, %s. Everything ok?",
						"action": "normal"
					},
					3: {
						"line": "Happy to lend an ear anytime, %s.",
						"action": "smile"
					},
					4: {
						"line": "WTF?!",
						"action": "confused"
					},
					6: {
						"line": "I'd kick your ass for it, actually.",
						"action": "yes"
					},
					8: {
						"line": "It's on like Donkey Kong!",
						"action": "angry"
					},
					10: {
						"line": null,
						"action": "fight"
					}
				}
			},
			2: {
				"lines": {
					5: {
						"line": "Ugh.",
						"action": "no"
					}
				}
			}
		}
	}
}

func get_dialogue(role:String, scene:int):
	return dialogue[role]["scene"][scene]["lines"]

func get_pronouns():
	return pronouns
