extends "res://scripts/Player.gd"

func _ready():
	pass # Replace with function body.

func throwBrochures():
	var brochure = Area2D.new()
	brochure.name = "brochure"
	var collisionShape = CollisionShape2D.new()
	collisionShape.shape = RectangleShape2D.new()
	brochure.add_child(collisionShape)
	brochure.collision_layer = enemy.get_node("HitBox").collision_mask
	
	var sprite = Sprite.new()
	sprite.texture = preload("res://characters/Terje/sprites/others/brochure.png")
	sprite.rotation_degrees = 90
	sprite.scale = Vector2(1.2, 1.2)
	brochure.add_child(sprite)
	
	var sprite2 = sprite.duplicate()
	sprite2.position = Vector2(-40, -40)
	brochure.add_child(sprite2)
	
	add_child(brochure)
	brochure.position = Vector2(230, 60)
	var tween = get_node("Tween")
	tween.interpolate_property(brochure, "position",
			brochure.position, Vector2(2000, brochure.position.y), 0.9,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func fatality():
	animTree.travel("fatality")
	# cancel the parent timer to prevent collapse
	get_parent().get_node("Timer").stop()
	
	# cancel the enemy's collapse timer
	if enemy.get_node_or_null("Timer"):
		enemy.get_node("Timer").disconnect("timeout", enemy, "collapse")
		enemy.get_node("Timer").queue_free()

func play_brochureClone():
	$BrochuresParticlesBig/BrochureClone.play()

func throwCyclone():
	print("p1 is at ", position.x)
	var tween = get_node("Tween")
#	$Boot.position.x = distance + $Boot.texture.get_width() * 0.25
#
#	$Boot.position.y = $Boot.texture.get_height() / -2
	var distance = 0
	if facing == "right":
		distance = abs(enemy.position.x - position.x)
	else:
		distance = abs(position.x - enemy.position.x)
	
	var from = Vector2(position.x, $BrochuresParticlesBig.position.y)
	var to = Vector2(distance, -40)
#	var from = Vector2(round(position.x), $BrochuresParticlesBig.position.y)
#	var to = Vector2(round(enemy.position.x-position.x), -40)
	print(from, " -> ", to)

	tween.interpolate_property($BrochuresParticlesBig, "position",
			from, to,  0.5,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func enemy_play_skeletonize_sound():
	enemy.skeletonize_sound()
	get_parent().format_text_for_label("fatality")
	get_parent().announcer("fatality")

func skeletonize_enemy():
	enemy.skeletonize()
