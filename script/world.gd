extends Node2D

@onready var display_size = get_viewport().get_visible_rect().size
@onready var player = get_node("/root/world/Player")
@onready var enemiesCount = get_node("/root/world/Enemies")
@onready var enemy = preload("res://scene/enemy.tscn")

func _process(delta):
	if enemiesCount.get_child_count() < 3:
		var newEnemy = enemy.instantiate()
		newEnemy.position.y = player.position.y - 250
		newEnemy.position.x = randf_range(0, player.position.y)	
		enemiesCount.add_child(newEnemy)
