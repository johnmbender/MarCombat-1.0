# MarCombat
A game, to conquer the world.

# TO DO, IN ORDER:
- blood squirts!
- Terje's barbeque animation
- sometimes when bot hit (usually Terje) his hitbox disappears
- more moo variations
- AI VS AI
- squish plays faster, as boot lands before it, unfortunately
- AI block chance increased
- can walk past oksana
- continue -> launch, music doesn't start
- re-record "my bad"
- scratch sound when ox paws, maybe more sounds in general
- more sounds when people punch (whoof sound)
- blood when she hits player


- randomize the number of pawings, and make Ox invincible until running
- no tossing people off building: gore instead, horn sticking out gut (add to player sprites?)
- ambience not playing
- can't hit Kelsie while she's dizzy
- John's self doubt smoke not gone while on ground
- delay the visibility of self-doubt in conversation a bit more
- if Kelsie's special gets interrupted, hair is lying on the field
- bots sometimes don't attack - ATTACK is left on somehow?? - maybe reset when timer resets, but timer isn't resetting
- NegaSmoke remains after Kelsie (only?) is fatality'd
- sometimes after an uppercut, all other attacks don't land?
- bots too easy; also, maybe make them increasingly harder
- fight music loop is bad
- sounds from people like: Kelsie: "owwwwwuh", etc
- Kelsie vs. Kelsie, on bootality: (muffled) I like your boots!
- Terje vs. Terje, on fatality: ?

1: Conversation scene
    - clear up text speed - fast when it shouldn't be
2: Story Mode controller
    - on lose, restart game, no continue
    - fighting self as "[Name]'s Self-Doubt"
3: Character selection scene
4: Polish
5: Multiplayer
- vs AI, fighting self as "Nega[Name]"

# IDEAS HEAP
- Ox Anna fight:
    - when hit, overplay the hit to head, and drop and slide there; pause, then get up, sound, and trot to the edge of screen, turn around, swipe leg like bulls do, particles some smoke out the nose, and go again
    - takes place on roof, include off the side of the building so that:
        - if the killing blow comes from the right (tossing player to the right) they fall off the building :)
        - if the killing blow comes from the left (player is on the right) they get gored, slammed on the ground, and trampled
    - if Oksana joins us as a player, she's still our first boss after self-doubt, but her story is different because of it; also, Ox Anna becomes a secret code :)
- conversation scene:
    - need one where player says "Hey!" and the opponent says "I don't like you" and they both go into fight pose, just because
    - maybe one for Kelsie v John (either way) where one asks how the other pronounces "gif" and the other says "gif" and they fight

# Littler To-Dos:
- add "finish him/her" sound
- add "PLAYER wins" sound
- more level backgrounds, and related effects (sounds, etc.)
    - catwalk, cafe, courtyard?, admissions, galleries, back hallway, break room, etc.
    - related sounds, etc (Pete in distance)
- bot specials working
- visually enhance Terje's special animation

# POLISH
- sound levels, better sound effects where necessary
- bug fixes and testing
- don't modulate the UI name bars
- outside weather? snow, rain, clear, night, etc.
- light effects?

# PRIORITY BUG FIXES
- chance of attack animations not cancelling and both players getting hit
    - possible solutions:
        - CODED, NOW TEST: stop AnimationPlayer, deactivate tree, reactivate tree WORKS?!?!?
            - works, but also seems to freeze player(s) sometimes, so need to see if tree is being disabled and can't return
        - AttackCircle and HitBox active/enabled switches are always opposite; this way you can't get hit while punching and vice versa; this doesn't remove the possibility of double hitting, tho, just lowers it
        - use advance method on the victim's animation to end it quicker
        - ?
- Terje
    - when facing left, fatality throws backwards and around
        - solution: don't let people walk past each other or throw?