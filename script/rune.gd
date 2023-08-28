extends Node2D
@onready var GLOBAL = get_node("/root/Global")
@onready var coinAudio = get_node("/root/world/SFX/coin")
@onready var powerUpAudio = get_node("/root/world/SFX/power_up")
@onready var healthAudio = get_node("/root/world/SFX/health")
@onready var shieldTimer = get_node("/root/world/Timer/ShieldTimer")
@onready var criticalTimer = get_node("/root/world/Timer/CriticalTimer")

func _ready():
	var dropLootProbability = randi_range(0, 10)
	if dropLootProbability == 0:
		GLOBAL.RUNE_TYPE = "POWER_UP"
	elif dropLootProbability == 1:
		GLOBAL.RUNE_TYPE = "SHIELD"
	elif dropLootProbability > 0 and dropLootProbability < 3:
		GLOBAL.RUNE_TYPE = "HEART"
	else:
		GLOBAL.RUNE_TYPE = "COIN"
		
	if GLOBAL.RUNE_TYPE == "COIN":
		$AnimatedSprite2D.play("coin")
	elif GLOBAL.RUNE_TYPE == "HEART":
		$AnimatedSprite2D.play("health")
	elif GLOBAL.RUNE_TYPE == "SHIELD":
		$AnimatedSprite2D.play("shield")
	else:
		$AnimatedSprite2D.play("power_up_damage")

func _on_area_2d_body_entered(body):
	if "Player" in body.name:
		if GLOBAL.RUNE_TYPE == "COIN":
			coinAudio.play()
			GLOBAL.SCORE += 2
		elif GLOBAL.RUNE_TYPE == "HEART":
			healthAudio.play()			
			GLOBAL.LIFE += 1
		elif GLOBAL.RUNE_TYPE == "SHIELD":
			healthAudio.play()			
			GLOBAL.SHIELD = true	
			shieldTimer.start()
		else:
			powerUpAudio.play()
			GLOBAL.CRITICAL = true
			criticalTimer.start()
		self.queue_free()

