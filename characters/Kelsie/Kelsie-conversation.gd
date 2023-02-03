extends AnimatedSprite

var pronouns
var dialogue

func _ready():
	pronouns = ["she", "her", "her"]
	dialogue = {
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
							"line": "Like hell you are! I worked hard on this!",
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
							"line": "I can't believe I just fought a coworker. This is insane. There must be some sort of HR protocol for this, but I need to talk to %s.",
							"action": "confused"
						},
						2: {
							"line": "I... it's hard to explain.",
							"action": "no"
						},
						5: {
							"line": "Right? I mean, it's a fantastic idea, but worth fighting over?",
							"action": "confused"
						},
						7: {
							"line": "You're kidding, right?",
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
							"line": "I got this. I've literally fought for this, and I am right to do so.",
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
						4: {
							"line": "Hey OG! Mind if I run an idea by you?",
							"action": "smile"
						},
						6: {
							"line": "Thanks, OG, you're the best.",
							"action": "smile"
						},
						8: {
							"line": "Oh, ha! They got it wrong again I guess.",
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
							"line": "Ok, you know what, I'm just going to send an email to someone higher up in the ministry.",
							"action": "yes"
						},
						1: {
							"line": "Oh wow, a response already! That was fast.",
							"action": "smile"
						},
						3: {
							"line": "That was weird. Well, I guess I better go if I want this idea to grow some legs.",
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
						1: {
							"line": "Hey s%, you ok? You don't look so good.",
							"action": "normal"
						},
						3: {
							"line": "Try. I'm here to listen, as a coworker but also a friend.",
							"action": "smile"
						},
						4: {
							"line": "Whoa... that's just...",
							"action": "confused"
						},
						6: {
							"line": "Yes, it totally is.",
							"action": "yes"
						},
						8: {
							"line": "It's on, bitch.",
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
							"line": "You make me sick.",
							"action": "no"
						}
					}
				}
			}
		}
	}
