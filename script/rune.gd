extends Node2D
@onready var GLOBAL = get_node("/root/Global")
@onready var coinAudio = get_node("/root/world/SFX/coin")

func _ready():
	var dropLootProbability = randi_range(0, 10)
	
	if dropLootProbability == 0:
		GLOBAL.RUNE_TYPE = "POWER_UP"
	elif dropLootProbability > 0 and dropLootProbability < 3:
		GLOBAL.RUNE_TYPE = "HEART"
	else:
		GLOBAL.RUNE_TYPE = "COIN"
		
	if GLOBAL.RUNE_TYPE == "COIN":
		$AnimatedSprite2D.play("coin")
	elif GLOBAL.RUNE_TYPE == "HEART":
		$AnimatedSprite2D.play("health")
	else:
		$AnimatedSprite2D.play("power_up_damage")

func _on_area_2d_body_entered(body):
	if "Player" in body.name:
		if GLOBAL.RUNE_TYPE == "COIN":
			$AnimatedSprite2D.play("coin")
			coinAudio.play()
			GLOBAL.SCORE += 2
		elif GLOBAL.RUNE_TYPE == "HEART":
			$AnimatedSprite2D.play("health")
			GLOBAL.LIFE += 1
		else:
			$AnimatedSprite2D.play("power_up_damage")
			GLOBAL.PLAYER_DAMAGE += 30
		
		self.queue_free()
