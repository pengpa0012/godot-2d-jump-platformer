extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var player = get_node("/root/world/Player")
@onready var display_size = get_viewport().get_visible_rect().size
@onready var healthBar = get_node("Healthbar/ProgressBar")
@onready var enemy = get_node("CollisionShape2D")
@onready var hitbox = get_node("Detectors/hitbox/CollisionShape2D")
@onready var sword = get_node("Detectors/sword/CollisionShape2D")
@onready var swordDetect = get_node("Detectors/sword")
@onready var attackRangeDetector = get_node("Detectors/attackRange")
@onready var GLOBAL = get_node("/root/Global")
@onready var hurtAudio = get_node("/root/world/SFX/enemy_hurt")
@onready var bloodAudio = get_node("/root/world/SFX/blood")
@onready var loot = preload("res://scene/rune.tscn")

var SPEED = 50.0
const stop_chance = 0.5
var move_timer = 3.0
var time_since_move = 0.0
var current_direction = 1
var isPlayerDetected = false
var isHurting = false
var CURRENT_HEALTH_COUNT = null
var MAX_HEALTH = null
var enableAttack = false
var isSpawning = true
var SWORD_OFFSET_COLLISION = 45
var currentEnemy = "skeleton"
var dropLoot = false
	
func _ready():
	time_since_move = move_timer
	current_direction = randf_range(-1, 1)
	if GLOBAL.SCORE < 200:
		currentEnemy = "bat"		
		SWORD_OFFSET_COLLISION = 0
		CURRENT_HEALTH_COUNT = 100
		MAX_HEALTH = 100
	elif GLOBAL.SCORE >= 200 and GLOBAL.SCORE <= 400:
		currentEnemy = "mushroom"
		SWORD_OFFSET_COLLISION = 10
		CURRENT_HEALTH_COUNT = 150
		MAX_HEALTH = 150
	elif GLOBAL.SCORE >= 400 and GLOBAL.SCORE <= 1000:
		currentEnemy = "goblin"		
		SWORD_OFFSET_COLLISION = 20
		CURRENT_HEALTH_COUNT = 250
		MAX_HEALTH = 250
	else:
		currentEnemy = "skeleton"
		SWORD_OFFSET_COLLISION = 45
		CURRENT_HEALTH_COUNT = 350
		MAX_HEALTH = 350
func _physics_process(delta):	
	if isSpawning:
		$AnimatedSprite2D.play("pop")
		await get_tree().create_timer(.5).timeout
		isSpawning = false
	else:
		for body in attackRangeDetector.get_overlapping_bodies():
			if "Player" in body.name:
				enableAttack = true
	#
		if CURRENT_HEALTH_COUNT > 0:
			time_since_move += delta	
			if not is_on_floor():
				velocity.y += gravity * delta
			if isPlayerDetected:
				SPEED = 60
				if self.position.x > player.position.x:
					current_direction = -1
				else:
					current_direction = 1
			elif time_since_move >= move_timer:
				if randf() < stop_chance:
					current_direction = 0
				else:
					SPEED = 50.0
					current_direction = randf_range(-1, 1)
				time_since_move = 0.0
			
			if velocity.x == 0 && !enableAttack:
				$AnimatedSprite2D.play(str(currentEnemy,"_idle"))
			elif isHurting:
				$AnimatedSprite2D.play(str(currentEnemy,"_hurt"))
			elif enableAttack:
				SPEED = 5
				$AnimatedSprite2D.play(str(currentEnemy,"_attack"))
				
				if $AnimatedSprite2D.frame == 6 || $AnimatedSprite2D.frame == 7:
					sword.disabled = false					
				else:
					sword.disabled = true
					
			else:
				$AnimatedSprite2D.play(str(currentEnemy,"_walk"))
				
			if current_direction < 0:
				sword.position.x = -SWORD_OFFSET_COLLISION
				$AnimatedSprite2D.flip_h = true
			else:
				sword.position.x = SWORD_OFFSET_COLLISION
				$AnimatedSprite2D.flip_h = false
				
			if self.position.x >= display_size.x:
				self.position.x = 0
			if self.position.x <= -10:
				self.position.x = display_size.x

			velocity.x = current_direction * SPEED
			move_and_slide()

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		isPlayerDetected = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		isPlayerDetected = false


func _on_hitbox_area_entered(area):
	if area.name == "Sword":
		isHurting = true
		bloodAudio.play()
		var scoreRange = randi_range(10, 15)
		GLOBAL.SCORE += scoreRange
		CURRENT_HEALTH_COUNT -= GLOBAL.PLAYER_DAMAGE	
		healthBar.value = (CURRENT_HEALTH_COUNT / MAX_HEALTH) * 100
		if CURRENT_HEALTH_COUNT <= 0:
			if not hurtAudio.playing && !enemy.disabled:
				hurtAudio.play()
			else:
				hurtAudio.stop()
			self.collision_layer = 2
			self.collision_mask = 2
			enemy.disabled = true
			hitbox.disabled = true
			healthBar.visible = false
			velocity.x = 0
			$AnimatedSprite2D.play(str(currentEnemy,"_death"))
		if area.global_position.x < self.global_position.x:
			velocity.x = 300 * 3
		else:
			velocity.x = -(300 * 3)
		move_and_slide()
			
			

func _on_hitbox_area_exited(area):
	if area.name == "Sword":
		isHurting = false

func _on_visible_on_screen_enabler_2d_screen_exited():
	if is_instance_valid(player):
		isSpawning = true
		if player.position.y < self.position.y:
			self.position.y -= display_size.y
		else:
			self.position.y += display_size.y
		self.position.x = randf_range(0, display_size.x)
	
func _on_attack_range_body_entered(body):
	if body.name == "Player":
		enableAttack = true

func _on_attack_range_body_exited(_body):
	if !$AnimatedSprite2D.is_playing():
		enableAttack = false
		sword.disabled = true


func _on_animated_sprite_2d_animation_finished():
	if is_instance_valid($AnimatedSprite2D) && not $AnimatedSprite2D.is_playing():
		sword.disabled = true
		enableAttack = false
		if CURRENT_HEALTH_COUNT <= 0:
			var dropLootProbability = randi_range(0, 10)
			if dropLootProbability > 0:
				var dropLoot = loot.instantiate()
				dropLoot.position.y = self.position.y
				dropLoot.position.x = self.position.x 
				get_tree().get_root().add_child(dropLoot)
			isSpawning = true
			GLOBAL.ENEMY_KILLED += 1
			$AnimatedSprite2D.play("pop")			
			await get_tree().create_timer(0.5).timeout	
			queue_free()
