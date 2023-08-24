extends Control
@onready var GLOBAL = get_node("/root/Global")
@onready var scoreLabel = get_node("CanvasGroup/CanvasLayer2/Score")
@onready var killLabel = get_node("CanvasGroup/CanvasLayer2/Life")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Score.text = "Score: {score}".format({"score": GLOBAL.SCORE})
	$Kills.text = "Total Kills: {kills}".format({"kills": GLOBAL.ENEMY_KILLED})


func _on_button_pressed():
	GLOBAL.SCORE = 0
	GLOBAL.LIFE = 3
	GLOBAL.ENEMY_KILLED = 0
	get_tree().change_scene_to_file("res://scene/world.tscn")


func _on_button_2_pressed():
	get_tree().quit()
