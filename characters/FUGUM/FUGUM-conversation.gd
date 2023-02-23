extends AnimatedSprite

var dialogue

var employee_number
onready var pronouns = ['w','t','f']

func _ready():
	randomize()
	employee_number = "00%s" % (randi() % 999999)
	
	dialogue = {
		"opponent": {
			"scene": {
				4: {
					"lines": {
						2: {
							"line": null,
							"action": "normal"
						},
						6: {
							"line": "Working on updates. 0% complete.\nDon't turn off your PC. This will take awhile.",
							"action": "updates"
						},
						11: {
							"line": "New message received.",
							"action": "message"
						},
						13: {
							"line": '"Dear %s, as we value innovation and strive for excellence, we have given your proposal significant consideration."' % employee_number,
							"action": "normal"
						},
						15: {
							"line": '"We request your presence at the Legislature Building in 15 minutes to discuss your proposal."',
							"action": "normal"
						},
						20: {
							"line": '"Greetings, employee number %s."' % employee_number,
							"action": "hidden"
						},
						22: {
							"line": '"I am faceless, unnamed government upper management."',
							"action": "hidden"
						},
						24: {
							"line": '"Hmmm. You know how when someone comes up with an idea that requires permission at ministerial or government level, you never truly find out who said no?"',
							"action": "hidden"
						},
						26: {
							"line": '"I am the one who makes those decisions. I am faceless, unnamed government upper management."',
							"action": "hidden"
						},
						28: {
							"line": '"Not quite that simple, %s."' % employee_number,
							"action": "hidden"
						},
						30: {
							"line": '"................... ok. %s."',
							"action": "hidden"
						},
						32: {
							"line": '"Definitely not. It is too innovative."',
							"action": "hidden"
						},
						34: {
							"line": '"Also strives for too much excellence, yes."',
							"action": "hidden"
						},
						36: {
							"line": '"I am impressed with your tenacity. The way you violently dispatched your co-workers for your goal is worthy of the truth I have shared with you."',
							"action": "hidden"
						},
						38: {
							"line": '"It is unfortunate that you must now know that they were only trying to protect you."',
							"action": "hidden"
						},
						40: {
							"line": '"Well, %s, now that you know who I am and that I exist, you must be dealt with. Find comfort in this rare truth."',
							"action": "hidden"
						},
						42: {
							"line": '"Metaphorically, yes. And slowly. For the rest of your time as our employee."',
							"action": "hidden"
						},
						44: {
							"line": '"Uh, I can answer that. It is more like a simulation, kinda like a game, but otherwise very real."',
							"action": "hidden"
						},
						46: {
							"line": '"You know, I am not exactly sure. The embodiment of your violent, animalistic urges? I do not remember my name! Oh god, WHO AM I? Am I god?"',
							"action": "hidden"
						},
						47: {
							"line": '"Ok, while you two question reality and doubt yourselves and each other, I have the matter of your idea to deal with. Prepare yourself, %s!"',
							"action": "hidden"
						},
						49: {
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

func _on_Voice_finished():
	# might have to go up a few levels, or use a signal, for god's sake
	get_parent().get_parent().voice_finished()
