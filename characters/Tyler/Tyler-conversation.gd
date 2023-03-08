extends AnimatedSprite

onready var info = {
	"name": "Tyler",
	"birthday": "between New Years Day and New Years Eve",
	"hometown": "Insectville, Saskatchewan",
}
onready var	pronouns = ["he","him","his"]
onready var dialogue = {
	"player": {
		"scene": {
			0: {
				"lines": {
					0: {
						"line": "I appreciate the help, %s. You helped a lot.",
						"action": "normal",
					},
					2: {
						"line": "Yep, I think Oksana will find it intriguing.",
						"action": "smile",
					},
					4: {
						"line": "What?",
						"action": "confused",
					},
					6: {
						"line": "Over my dead body! I worked hard on this!",
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
						"line": "Man, that felt good! And I'm scaring myself a bit there.",
						"action": "smile"
					},
					1: {
						"line": "Hey %s! Would you mind coming here for a second?",
						"action": "normal"
					},
					3: {
						"line": "You would not believe what just happened... ",
						"action": "no"
					},
					7: {
						"line": "I know, right? But is it really something fighting someone over?",
						"action": "confused"
					},
					9: {
						"line": "%s?",
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
						"line": "...",
						"action": "angry"
					},
					2: {
						"line": "Up yours, %s.",
						"action": "angry"
					},
					4: {
						"line": "I don't like you.",
						"action": "fight"
					}
				}
			},
			3: {
				"lines": {
					0: {
						"line": "Seriously... what am I doing? Why am I so angry?",
						"action": "confused"
					},
					1: {
						"line": "This is crazy. I am crazy.",
						"action": "no",
					},
					2: {
						"line": "I should go look at some exoskeletons or something...",
						"action" :"no"
					},
					3: {
						"line": "... stick to what I know.",
						"action": "angry"
					},
					4: {
						"line": "What in the ...",
						"action": "offended"
					},
					6: {
						"line": null,
						"action": "fight"
					}
				}
			},
			4: {
				"lines": {
					0: {
						"line": "What a straaaaange day.",
						"action": "confused"
					},
					1: {
						"line": "I'd better just go find Oksana.",
						"action": "smile"
					},
					2: {
						"line": "I've heard she loves coffee. I'll go buy her one.",
						"action": "yes"
					},
					3: {
						"line": "Things can't get any worse, right?",
						"action": "no"
					},
					5: {
						"line": "Oksana! Jayne pointed me up here when I went looking for you. I have something I'd like to talk to you about.",
						"action": "smile"
					},
					7: {
						"line": "You're welcome. Your employees, by the way...",
						"action": "yes"
					},
					9: {
						"line": "I sometimes get 'Taylor', but that is funny right there!",
						"action": "smile"
					},
					11: {
						"line": null,
						"action": "offended"
					},
				}
			},
			5: {
				"lines": {
					0: {
						"line": "That was delicious.",
						"action": "smile"
					},
					1: {
						"line": "... and sooooo wrong. Oh geez, it's late!",
						"action": "yes"
					},
					3: {
						"line": "I'll send an email to someone higher in the ministry and check again tomorrow.",
						"action": "normal"
					},
					5: {
						"line": "Love it. Annnd... se-",
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
						"line": "Sleep. I need sleep.",
						"action": "normal"
					},
					12: {
						"line": "Whoa. Must just be an auto-responder.",
						"action": "confused"
					},
					14: {
						"line": "Ok, ok, I like how this is sounding.",
						"action": "smile"
					},
					16: {
						"line": "There's no name on this... who sent this?",
						"action": "confused"
					}, 
					17: {
						"line": "I should head down there and get on with this.",
						"action": "yes"
					},
					19: {
						"line": "I didn't think this completely through. Where do I go at this hour?",
						"action": "confused"
					},
					21: {
						"line": ".... uh, hello?",
						"action": "confused"
					},
					23: {
						"line": "I... what?.",
						"action": "confused"
					},
					25: {
						"line": "Haha, yes. Yes.",
						"action": "yes"
					},
					27: {
						"line": "Like a shadow government?",
						"action": "confused"
					},
					29: {
						"line": "That sounds weird. Call me Tyler.",
						"action": "normal"
					},
					31: {
						"line": "So my idea is approved then?",
						"action": "yes"
					},
					33: {
						"line": "TOO innovative?!",
						"action": "offended"
					}, 
					35: {
						"line": "You really had me come down here just to tell me no?",
						"action": "no"
					},
					37: {
						"line": "Okay...",
						"action": "confused"
					},
					39: {
						"line": "Protect me from what?",
						"action": "confused"
					},
					41: {
						"line": "Are you going to kill me?!",
						"action": "offended"
					},
					43: {
						"line": "Metaphorically? Is this all not happening right now? I mean ...",
						"action": "confused"
					},
					45: {
						"line": "Ah geez, now who are you?",
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
						"line": "Happy to help! Nice idea, too.",
						"action": "smile"
					},
					3: {
						"line": "I might have to steal it, though. I could use a win.",
						"action": "yes"
					},
					5: {
						"line": "Yeah, I'm gonna go catch Oksana right now, see ya!",
						"action": "smile"
					},
					7: {
						"line": "Pfffft. Whatever, loser.",
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
						"line": "Whoa, %s, you look like hell.",
						"action": "normal"
					},
					4: {
						"line": "If you feel like talking, I'll listen.",
						"action": "smile"
					},
					6: {
						"line": "That's insane!",
						"action": "confused"
					},
					8: {
						"line": "For a thank-you e-card? Hell yes!",
						"action": "yes"
					},
					10: {
						"line": "They're an integral form of recognition!",
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
					1: {
						"line": "Hey %s! How's it going?",
						"action": "smile"
					},
					3: {
						"line": "Whoa, what's your damn problem?",
						"action": "offended"
					},
					5: {
						"line": null,
						"action": "fight"
					}
				}
			},
			3: {
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
