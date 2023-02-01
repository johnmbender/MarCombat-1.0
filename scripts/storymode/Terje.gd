var dialogue = {
	"player": {
		"scene": {
			0: {
				"lines": [
					"Thanks for the help, %s. Your feedback was invaluable.",
					"Yeah, I'm excited to share it with Oksana now.",
					"Excuse me?",
					"I don't think so!",
				],
				"actions": [
					"normal", "smile", "confused", "angry"
				],
			},
			1: {
				"lines": [
					"I can't believe that just happened. This isn't right.  I should probably contact HR, but I need to talk to %s.",
					"Yeah... it's... ",
					"I'm excited about it, but is it really worth fighting over?",
					"You must be joking."
				],
				"actions": [
					"confused", "confused", "yes", "shocked"
				]
			},
			2: {
				"lines": [
					"Why am I doing this? Why am I fighting at all?",
					"It's just an idea. A silly idea.",
					"I should just forget about it...",
					"Is that... is that ME?!"
				],
				"actions": [
					"confused", "no", "yes", "shocked"
				]
			},
			3: {
				"lines": [
					"I'm in. I'm determined to make this happen.",
					"I'll go talk to Oksana. She has a way with things like this.",
					"I'll buy her a coffee, and maybe she won't turn on me like the others.",
					"Today's been a bit much.",
					"Hey Oksana, do you have a moment to chat about something?",
					"Thanks, Oksana, those are great ideas.",
					"What? I even spelled it for them."
				],
				"actions": [
					"yes", "smile", "yes", "no", "smile", "smile", "smile"
				]
			},
			4: {
				"lines": [
					"I'm just going to send an email up the ministry.",
					"They replied already? This should be interesting.",
					"What a strange sound. What is that?!"
				],
				"actions": [
					"yes", "smile", "confused"
				]
			}
		},
	},
	"opponent": {
		"scene": {
			0: {
				"lines": [
					"You're so welcome, and it's an amazing idea, by the way.",
					"I might just have to take the credit for your idea, you know.",
					"I'm heading there right now, see ya.",
					"This ends now.",
				],
				"actions": [
					"smile", "normal", "normal", "angry"
				]
			},
			1: {
				"lines": [
					"Hey %s, are you feeling alright? You don't look well.",
					"You can share and I will listen.",
					"What? That's crazy.",
					"I'm thinking yes.",
					"It's on, jackass."
				],
				"actions": [
					"normal", "smile", "confused", "yes", "angry"
				]
			},
			2: {
				"lines": [
					"I'm embarrasssed to be you."
				],
				"actions": [
					"no"
				]
			}
		}
	}
}
