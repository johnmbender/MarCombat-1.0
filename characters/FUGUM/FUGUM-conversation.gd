extends AnimatedSprite

var dialogue

var employee_number
onready var pronouns = ['w','t','f']
signal voice_finished
var conversation_controller

func set_controller(controller):
	conversation_controller = controller
	var _unused = connect("voice_finished", conversation_controller, "voice_finished")

func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	employee_number = "00%s" % random.randi_range(100000,999999)
	
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
							"line": "",
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
							"line": '"You know how when someone comes up with an idea that requires permission at ministerial or cabinet level, you never truly find out who said no?"',
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
							"line": '"................... ok ........... %s."',
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
							"line": '"It is unfortunate that you must now know that they were only trying to protect you. Except Oxaca. She had issues."',
							"action": "hidden"
						},
						40: {
							"line": '"Well, now that you know who I am and that I exist, you must be dealt with. May you find comfort in knowing this truth."',
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
							"line": '"You know, I am not really sure. The embodiment of your violent, animalistic urges? I do not remember my name! Oh god, WHO AM I? Am I god?"',
							"action": "hidden"
						},
						47: {
							"line": '"Ok, while you two question reality and doubt yourselves and each other, I have the matter of your idea to deal with. Prepare yourself!"',
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

var characters_spoken = 0
func read_employee_number():
	var num_to_read = employee_number.substr(characters_spoken, 1)
	$Voice.stream = load("res://sounds/characters/FUGUM/num-%s.wav" % num_to_read)
	$Voice.play()
	print("employee_number: ", employee_number, " - played ", characters_spoken, " of ", employee_number.length(), ": ", num_to_read)
	characters_spoken += 1
	if characters_spoken == employee_number.length()-1:
		emit_signal("voice_finished")

func _on_Voice_finished():
	var resource_path = $Voice.stream.resource_path
	var path_array = resource_path.split("/")
	var current = path_array[path_array.size()-1]
	match current:
		"20.wav":
			read_employee_number()
			return
		"28.wav":
			characters_spoken = 0
			read_employee_number()
			return
		"num-0.wav","num-1.wav","num-2.wav","num-3.wav","num-4.wav","num-5.wav","num-6.wav","num-7.wav","num-8.wav","num-9.wav":
			read_employee_number()
			return
	emit_signal("voice_finished")
		
