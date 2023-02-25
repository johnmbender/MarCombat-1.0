extends AnimatedSprite

onready var info = {
	"name": "Kelsie",
	"birthday": "single-digits January",
	"hometown": "St. Albert, Alberta"
}
onready var pronouns = ["she", "her", "her"]
onready var dialogue = {
	"player": {
		"scene": {
			0: {
				"lines": {
					0: {
						"line": "I really appreciate you helping me work out the kinks, %s!",
						"action": "normal",
					},
					2: {
						"line": "Thanks! I'm pretty excited to talk to Oksana about it.",
						"action": "smile",
					},
					4: {
						"line": "I'm sorry, what?",
						"action": "confused",
					},
					6: {
						"line": "Hells no! I worked hard on this!",
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
						"line": "I can't believe I just fought a coworker. I should probably talk to HR about it...",
						"action": "confused"
					},
					1: {
						"line": "Oh, hey %s!",
						"action": "yes"
					},
					3: {
						"line": "I... it's hard to explain.",
						"action": "no"
					},
					7: {
						"line": "Right? I mean, it's a fantastic idea, but worth fighting over?",
						"action": "confused"
					},
					9: {
						"line": "You're kidding, right?",
						"action": "shocked"
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
						"line": "I can't do this. What am I doing fighting my coworkers?",
						"action": "confused"
					},
					1: {
						"line": "It's just a dumb idea. Why am I taking this so far?",
						"action": "no",
					},
					2: {
						"line": "I should just go sit at my desk, check my emails, and forget about this...",
						"action" :"no"
					},
					3: {
						"line": "... this ridiculous idea. My stupid, ridiculous idea.",
						"action": "angry"
					},
					4: {
						"line": "Is that... is that me?!",
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
						"line": "Well, that certainly won't require years of therapy.",
						"action": "yes"
					},
					1: {
						"line": "I'll go talk to Oksana. She has a brilliant mind for these sorts of things.",
						"action": "smile"
					},
					2: {
						"line": "Maybe I'll bring her a coffee, just to make sure I stay on her good side.",
						"action": "yes"
					},
					3: {
						"line": "I've had enough drama for today.",
						"action": "no"
					},
					5: {
						"line": "Hey OG! Jayne told me you were up here. Mind if I run an idea by you?",
						"action": "smile"
					},
					7: {
						"line": "You're very welcome! And, thanks, OG, you're the best.",
						"action": "smile"
					},
					9: {
						"line": "Oh, ha! They got it wrong again I guess.",
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
						"line": "Mmmmm... that was delicious.",
						"action": "smile"
					},
					1: {
						"line": "... and a little traumatizing, not gonna lie. Whoa, it's late!",
						"action": "yes"
					},
					3: {
						"line": "I should run downstairs and just send an email to someone higher up in the ministry, go home and sleep, and hope tomorrow is a bit more normal.",
						"action": "normal"
					},
					5: {
						"line": "Perfect! Annnd... se-",
						"action": "smile"
					},
					7: {
						"line": "MOTHER F-",
						"action": "shocked"
					},
					9: {
						"line": "Send.",
						"action": "angry"
					},
					10: {
						"line": "Well, that's done. Now I can go home and rest.",
						"action": "normal"
					},
					12: {
						"line": "That was quick - must be an auto-responder.",
						"action": "confused"
					},
					14: {
						"line": "Yay! Ok, good start...",
						"action": "smile"
					},
					16: {
						"line": "That's strange, no signature. I wonder who this is?",
						"action": "confused"
					}, 
					17: {
						"line": "Well, I guess it's better I do this now and not run into any more hostile coworkers.",
						"action": "yes"
					},
					19: {
						"line": "Now that I think about it, where do I go? I can't imagine the Ledge is open at this hour.",
						"action": "confused"
					},
					21: {
						"line": "Where'd that voice come from? Who are you??",
						"action": "confused"
					},
					23: {
						"line": "I am confused.",
						"action": "confused"
					},
					25: {
						"line": "Oh, most definitely.",
						"action": "yes"
					},
					27: {
						"line": "So, you're like a shadow government?",
						"action": "confused"
					},
					29: {
						"line": "I'd prefer it if you called me by my name.",
						"action": "normal"
					},
					31: {
						"line": "So.... does this mean my idea has been approved?",
						"action": "confused"
					},
					33: {
						"line": "TOO innovative?!",
						"action": "shocked"
					}, 
					35: {
						"line": "So why did you ask me to come down here just to tell me no?",
						"action": "angry"
					},
					37: {
						"line": ".....",
						"action": "confused"
					},
					39: {
						"line": "Protect me? From what?",
						"action": "confused"
					},
					41: {
						"line": "Are you going to kill me?!",
						"action": "shocked"
					},
					43: {
						"line": "Metaphorically? What is this, am I dreaming? Is this like... like the Matrix?!",
						"action": "confused"
					},
					45: {
						"line": "Oh! I thought I was hearing a voice. I'm glad I'm not losing my mind. Or am I? Then who are you, voice?",
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
						"line": "No problem! Happy to help. It's a really great idea, %s.",
						"action": "smile"
					},
					3: {
						"line": "Yeah, well, I think I'm going to have to take the credit for it.",
						"action": "normal"
					},
					5: {
						"line": "I'm going to go talk to her right now. Byeee!",
						"action": "normal"
					},
					7: {
						"line": "Pshh. What are you going to do about it, %s?",
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
						"line": "Hey %s, you ok? You don't look so good.",
						"action": "normal"
					},
					4: {
						"line": "Try. I'm here to listen, as a coworker but also a friend.",
						"action": "smile"
					},
					6: {
						"line": "Whoa... that's just...",
						"action": "confused"
					},
					8: {
						"line": "The chance to punch you in the face for kudos? Definitely.",
						"action": "yes"
					},
					10: {
						"line": "Bring that ugly face to my fist, bitch!",
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
