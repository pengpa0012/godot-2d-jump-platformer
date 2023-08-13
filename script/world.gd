extends Node2D

@onready var display_size = get_viewport().get_visible_rect().size
@onready var player = get_node("/root/world/Player")
@onready var enemiesCount = get_node("/root/world/Enemies")
@onready var enemy = preload("res://scene/enemy.tscn")
@onready var GLOBAL = get_node("/root/Global")
@onready var scoreLabel = get_node("CanvasGroup/CanvasLayer2/Score")
@onready var lifeLabel = get_node("CanvasGroup/CanvasLayer2/Life")

func _process(_delta):
	scoreLabel.text = "Score: {score}".format({"score": GLOBAL.SCORE})
	lifeLabel.text = "Life: {life}".format({"life": GLOBAL.LIFE})
	print(GLOBAL.ENEMY_KILLED * GLOBAL.ENEMY_MULTIPLIER)
	if enemiesCount.get_child_count() <= 1:
		for i in range(GLOBAL.ENEMY_KILLED * GLOBAL.ENEMY_MULTIPLIER):
			var newEnemy = enemy.instantiate()
			newEnemy.position.y = player.position.y - 130
			newEnemy.position.x = randf_range(0, player.position.x)
			enemiesCount.add_child(newEnemy)
		
	if GLOBAL.RESPAWN_PLAYER:
		GLOBAL.RESPAWN_PLAYER = false
		GLOBAL.HEALTH_COUNT = 10
		player.position.x = randi_range(0, display_size.x - 100)	
