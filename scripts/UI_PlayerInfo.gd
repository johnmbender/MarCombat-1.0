extends Control

func _ready():
	$Player1/SkullContainer/Skull.visible = false
	$Player2/SkullContainer/Skull.visible = false

func set_player_name(player:int, name:String):
	get_node("Player%s/HBoxContainer/Name" % player).text = name

func get_player_name(player:int):
	return get_node("Player%s/HBoxContainer/Name" % player).text

func set_player_health(player:int, health:int):
	get_node("Player%s/HealthBar" % player).value = health

func show_skull(player: int):
	get_node("Player%s/SkullContainer/Skull" % player).visible = true

func flip():
	pass # ?
#	rect_scale.x = -1
#	$CenterContainer/Name.rect_scale.x = 1
#	$CenterContainer.alignment = BoxContainer.ALIGN_END
