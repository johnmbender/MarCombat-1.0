extends AnimatedSprite

onready var	pronouns = ["he","him","his"]
onready var dialogue = {
	"player": {
		"scene": {
			0: {
				"lines": {
					0: {
						"line": "Thanks for the help, %s. Your feedback was invaluable.",
						"action": "normal",
					},
					2: {
						"line": "Yeah, I'm excited to share it with Oksana now.",
						"action": "smile",
					},
					4: {
						"line": "Excuse me?",
						"action": "confused",
					},
					6: {
						"line": "I don't think so!",
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
						"line": "I can't believe that just happened. This isn't right.  I should probably contact HR, but I need to talk to %s.",
						"action": "confused"
					},
					2: {
						"line": "Yeah... it's... ",
						"action": "no"
					},
					5: {
						"line": "I'm excited about it, but is it really worth fighting over?",
						"action": "confused"
					},
					7: {
						"line": "%s, you must be joking.",
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
						"line": "Why am I doing this? Why am I fighting at all?",
						"action": "confused"
					},
					1: {
						"line": "It's just an idea. A silly idea.",
						"action": "no",
					},
					2: {
						"line": "I should just forget about it...",
						"action" :"no"
					},
					3: {
						"line": "Is that... is that ME?!",
						"action": "angry"
					},
					4: {
						"line": null,
						"action": "fight"
					}
				}
			},
			3: {
				"lines": {
					0: {
						"line": "I'm in. I'm determined to make this happen.",
						"action": "yes"
					},
					1: {
						"line": "I'll go talk to Oksana. She has a way with things like this.",
						"action": "smile"
					},
					2: {
						"line": "I'll buy her a coffee, and maybe she won't turn on me like the others.",
						"action": "yes"
					},
					3: {
						"line": "Today's been a bit much.",
						"action": "no"
					},
					4: {
						"line": "Hey Oksana, do you have a moment to chat about something?",
						"action": "smile"
					},
					6: {
						"line": "Thanks, Oksana, those are great ideas.",
						"action": "smile"
					},
					8: {
						"line": "What? I even spelled it for them.",
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
						"line": "I'm just going to send an email up the ministry.",
						"action": "yes"
					},
					1: {
						"line": "They replied already? This should be interesting.",
						"action": "smile"
					},
					3: {
						"line": "What a strange sound. What is that?!",
						"action": "confused"
					}
				}
			}
		},
	},
	"opponent": {
		"scene": {
			0: {
				"lines": {
					1: {
						"line": "You're very welcome and it's an amazing idea, by the way.",
						"action": "smile"
					},
					3: {
						"line": "Buuuuut.... I might just have to take the credit for your idea, %s.",
						"action": "yes"
					},
					5: {
						"line": "Yeah, I'm heading there right now, see ya.",
						"action": "normal"
					},
					7: {
						"line": "You mean *I* worked hard on this.",
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
						"line": "Hey %s, are you feeling alright? You don't look well.",
						"action": "normal"
					},
					3: {
						"line": "You can share and I will listen.",
						"action": "smile"
					},
					4: {
						"line": "What? That's crazy.",
						"action": "confused"
					},
					6: {
						"line": "I'm thinking yes.",
						"action": "yes"
					},
					8: {
						"line": "It's on, jackass.",
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
						"line": "I'm embarrasssed to be you.",
						"action": "no"
					}
				}
			}
		}
	}
}


func get_dialogue(role:String, scene: int):
	return dialogue[role]["scene"][scene]["lines"]

func get_pronouns():
	return pronouns
