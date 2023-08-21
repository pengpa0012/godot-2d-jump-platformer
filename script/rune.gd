extends Node2D
@onready var GLOBAL = get_node("/root/Global")

func _process(delta):
	$AnimatedSprite2D.play("coin")


func _on_area_2d_body_entered(body):
	if "Player" in body.name:
		GLOBAL.SCORE += 2
		self.queue_free()
