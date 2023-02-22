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
						"line": "Seriously. What just happened?",
						"action": "confused"
					},
					1: {
						"line": "Oh, hey, %s! Over here!",
						"action": "yes"
					},
					3: {
						"line": "You won't believe this...",
						"action": "no"
					},
					7: {
						"line": "Don't get me wrong. Helluva idea, but worth fighting someone for?",
						"action": "confused"
					},
					9: {
						"line": "Seriously?!",
						"action": "offended"
					},
					11: {
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
						"line": "I feel better, strangely.",
						"action": "yes"
					},
					1: {
						"line": "Oksana will know what to do.",
						"action": "smile"
					},
					2: {
						"line": "I'll buy her a coffee, she'll like that.",
						"action": "yes"
					},
					3: {
						"line": "That way she won't beat me up for my idea. Hopefully...",
						"action": "no"
					},
					5: {
						"line": "Hey Oksana. Jayne said you were up here. Have a moment?",
						"action": "smile"
					},
					7: {
						"line": "My pleasure! So, I have an idea I wanted to run by you...",
						"action": "smile"
					},
					9: {
						"line": "Man, they NEVER get your name right. Haha!",
						"action": "smile"
					},
					11: {
						"line": null,
						"action": "shocked"
					},
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
					2: {
						"line": "You don't look so great, %s. Everything ok?",
						"action": "normal"
					},
					4: {
						"line": "Happy to lend an ear anytime, %s.",
						"action": "smile"
					},
					6: {
						"line": "WTF?!",
						"action": "confused"
					},
					8: {
						"line": "That would land me a Premier's Award of Excellence, maybe, yeah.",
						"action": "yes"
					},
					10: {
						"line": "It comes with, like, $100 after taxes!",
						"action": "angry"
					},
					12: {
						"line": null,
						"action": "fight"
					}
				}
			},
			2: {
				"lines": {
					5: {
						"line": null,
						"action": "fight"
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
