extends AnimatedSprite

onready var info = {
	"name": "Terje",
	"birthday": "annually",
	"hometown": "Past Vegreville, turn right at that gas station",
}
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
						"line": "I can't believe that just happened. This isn't right.",
						"action": "confused"
					},
					1: {
						"line": "%s! Can I talk to you for a sec, please?",
						"action": "yes"
					},
					3: {
						"line": "Yeah... it's... ",
						"action": "no"
					},
					7: {
						"line": "I'm excited about it, but is it really worth fighting over?",
						"action": "confused"
					},
					9: {
						"line": "%s, you must be joking.",
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
						"line": "... maybe check Sprout Social.",
						"action": "angry"
					},
					4: {
						"line": "Is that... is that ME?!",
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
						"line": "I'll go talk to Oksana. She has a way with things like this.",
						"action": "smile"
					},
					2: {
						"line": "I'll get her a coffee, and maybe she won't turn on me like the others.",
						"action": "yes"
					},
					3: {
						"line": "Today's been a biiiitt much.",
						"action": "no"
					},
					5: {
						"line": "Hey Oksana! Jayne said you were up here. Do you have a moment to chat about something?",
						"action": "smile"
					},
					7: {
						"line": "Yep! Thanks, Oksana, I appreciate the help!",
						"action": "yes"
					},
					9: {
						"line": "What? I even spelled it for them. That's hilarious!",
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
						"line": "Best steak I've had in years...",
						"action": "smile"
					},
					1: {
						"line": "... with a side of guilt. Oh wow it's late.",
						"action": "yes"
					},
					3: {
						"line": "I should send an email up the ministry, get some sleep, and pick this up tomorrow.",
						"action": "normal"
					},
					5: {
						"line": "Nice. Annnd... se-",
						"action": "smile"
					},
					7: {
						"line": "MOTHER F-",
						"action": "offended"
					},
					9: {
						"line": "Send.",
						"action": "angry"
					},
					10: {
						"line": "Now I can go home and rest.",
						"action": "normal"
					},
					12: {
						"line": "That was fast. Must just be an auto-responder.",
						"action": "confused"
					},
					14: {
						"line": "Alright. Alright. I like where this is going.",
						"action": "smile"
					},
					16: {
						"line": "That's weird, no signature. I wonder who sent this?",
						"action": "confused"
					}, 
					17: {
						"line": "Probably better to go do this now and not get into any more fights.",
						"action": "yes"
					},
					19: {
						"line": "Now that I am here, where am I supposed to go? The Ledge can't be open right now.",
						"action": "confused"
					},
					21: {
						"line": "Who... is speaking?",
						"action": "confused"
					},
					23: {
						"line": "I don't understand...",
						"action": "confused"
					},
					25: {
						"line": "Been there, have the t-shirt.",
						"action": "yes"
					},
					27: {
						"line": "Like a shadow government?",
						"action": "confused"
					},
					29: {
						"line": "That's awkward. Call me by my name.",
						"action": "normal"
					},
					31: {
						"line": "So my idea is approved then?",
						"action": "angry"
					},
					33: {
						"line": "TOO innovative?!",
						"action": "shocked"
					}, 
					35: {
						"line": "Why would you have me come down here just to tell me no?",
						"action": "angry"
					},
					37: {
						"line": "Uh...",
						"action": "confused"
					},
					39: {
						"line": "Protect me from what?",
						"action": "confused"
					},
					41: {
						"line": "Are you going to kill me?!",
						"action": "shocked"
					},
					43: {
						"line": "What do you mean metaphorically? Is this a dream?",
						"action": "confused"
					},
					45: {
						"line": "Oh great, another voice - who are YOU?",
						"action": "confused"
					},
					48: {
						"line": "",
						"action": "fight"
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
						"line": "Yeeaaaahhhh.... I might just have to take the credit for your idea, %s.",
						"action": "yes"
					},
					5: {
						"line": "Yeah, I'm gonna run up there before you do. Your word against mine.",
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
					2: {
						"line": "Hey %s, are you feeling alright? You don't look well.",
						"action": "normal"
					},
					4: {
						"line": "I'm here to listen, friend.",
						"action": "smile"
					},
					6: {
						"line": "What? That's crazy.",
						"action": "confused"
					},
					8: {
						"line": "For a congratulatory email to all ministry? Absolutely.",
						"action": "yes"
					},
					10: {
						"line": "Everyone reads those!",
						"action": "offended"
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


func get_dialogue(role:String, scene: int):
	return dialogue[role]["scene"][scene]["lines"]

func get_pronouns():
	return pronouns
