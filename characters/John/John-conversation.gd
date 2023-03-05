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
						"line": "Thanks. I think Oksana's gonna love it ...",
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
						"line": "...",
						"action": "angry"
					},
					2: {
						"line": "Piss off.",
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
			4: {
				"lines": {
					0: {
						"line": "That was cathartic.",
						"action": "yes"
					},
					1: {
						"line": "Oksana will know what to do, I hope.",
						"action": "smile"
					},
					2: {
						"line": "I'll buy her a coffee. She loves her coffee.",
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
						"action": "offended"
					},
				}
			},
			5: {
				"lines": {
					0: {
						"line": "Well, that was a Ms. Steak.",
						"action": "smile"
					},
					1: {
						"line": "... and I don't want to think about it. Crap, it's really late!",
						"action": "yes"
					},
					3: {
						"line": "Maybe I'll just send an email up the ministry and see if I get a response tomorrow.",
						"action": "normal"
					},
					5: {
						"line": "Cool. Annnd... se-",
						"action": "smile"
					},
					7: {
						"line": "MOTHER F-",
						"action": "shocked"
					},
					9: {
						"line": "Send.",
						"action": "smile"
					},
					10: {
						"line": "I should go home and sleep..",
						"action": "normal"
					},
					12: {
						"line": "That's wild. Already a response?",
						"action": "confused"
					},
					14: {
						"line": "Ok, cool. I like where this is going...",
						"action": "smile"
					},
					16: {
						"line": "That's weird, no signature. I wonder who this is?",
						"action": "confused"
					}, 
					17: {
						"line": "After today's events it'd be nice to get this over with, for good or bad.",
						"action": "yes"
					},
					19: {
						"line": "Ledge isn't open in the middle of the night... too tired to think straight. Where should I go?",
						"action": "confused"
					},
					21: {
						"line": "Gah! Who is that?",
						"action": "confused"
					},
					23: {
						"line": "What?!",
						"action": "confused"
					},
					25: {
						"line": "Oh god, yes.",
						"action": "yes"
					},
					27: {
						"line": "So, you're like a shadow government?",
						"action": "confused"
					},
					29: {
						"line": "A number. Soooo personal.",
						"action": "normal"
					},
					31: {
						"line": "So my idea is approved?",
						"action": "confused"
					},
					33: {
						"line": "TOO innovative?!",
						"action": "shocked"
					}, 
					35: {
						"line": "I came down here, this late, for you to just say no?",
						"action": "angry"
					},
					37: {
						"line": "Oh, well then...",
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
						"line": "Metaphorically? I'm literally standing here. Or am I? I'm so confused.",
						"action": "confused"
					},
					45: {
						"line": "Now there's two of you? Who are you?",
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
					1: {
						"line": "Hi %s! How's your day going?",
						"action": "smile"
					},
					3: {
						"line": "Damn, what the hell did I do to you?!",
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
			},
		}
	}
}

func get_dialogue(role:String, scene:int):
	return dialogue[role]["scene"][scene]["lines"]

func get_pronouns():
	return pronouns
