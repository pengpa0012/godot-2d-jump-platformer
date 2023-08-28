extends Node2D

@onready var display_size = get_viewport().get_visible_rect().size
@onready var player = get_node("/root/world/Player")
@onready var enemiesCount = get_node("/root/world/Enemies")
@onready var enemy = preload("res://scene/enemy.tscn")
@onready var GLOBAL = get_node("/root/Global")
@onready var scoreLabel = get_node("CanvasGroup/CanvasLayer2/Score")
@onready var lifeLabel = get_node("CanvasGroup/CanvasLayer2/Life")
@onready var pauseMenu = get_node("CanvasGroup/CanvasLayer2/PauseMenu")

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu.visible = true
	
	if pauseMenu.visible:
		get_tree().paused = true
	scoreLabel.text = "Score: {score}".format({"score": GLOBAL.SCORE})
	lifeLabel.text = "Life: {life}".format({"life": GLOBAL.LIFE})
	if enemiesCount.get_child_count() <= 3:
		for i in range(GLOBAL.ENEMY_KILLED):
			var newEnemy = enemy.instantiate()
			newEnemy.position.y = randf_range(player.position.y - 130, player.position.y + -display_size.y)
			newEnemy.position.x = randf_range(0, player.position.x)
			enemiesCount.add_child(newEnemy)
		
	if GLOBAL.RESPAWN_PLAYER:
		GLOBAL.RESPAWN_PLAYER = false
		GLOBAL.HEALTH_COUNT = 10
		player.position.x = randi_range(0, display_size.x - 100)

func _on_resume_pressed():
	pauseMenu.visible = false
	get_tree().paused = false


func _on_quit_pressed():
	get_tree().quit()


func _on_deadzone_body_entered(body):
	body.queue_free()

func _on_shield_timer_timeout():
	GLOBAL.SHIELD = false


func _on_critical_timer_timeout():
	GLOBAL.CRITICAL = false
