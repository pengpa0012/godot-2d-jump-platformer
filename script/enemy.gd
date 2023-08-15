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

var SPEED = 50.0
const stop_chance = 0.5
var move_timer = 3.0
var time_since_move = 0.0
var current_direction = 1
var isPlayerDetected = false
var isHurting = false
var HEALTH_COUNT = 5
var enableAttack = false
var isSpawning = true
var enemySprite = null
var SWORD_OFFSET_COLLISION = 45
# Enemy attack offfset
#bat - 0
#goblin - 20
#mushroom - 10
#skeleton - 45

func _init():
	var skeleton = preload("res://scene/enemy_skeleton.tscn") 
	var goblin = preload("res://scene/enemy_goblin.tscn") 
	var mushroom = preload("res://scene/enemy_mushroom.tscn") 
	var bat = preload("res://scene/enemy_bat.tscn")
	enemySprite = skeleton.instantiate()
	self.add_child(enemySprite)
	
func _ready():
	time_since_move = move_timer
	current_direction = randf_range(-1, 1)

func _physics_process(delta):
	if is_instance_valid(enemySprite) && not enemySprite.is_playing():
		sword.disabled = true
		enableAttack = false
		if HEALTH_COUNT <= 0:
			isSpawning = true
			GLOBAL.ENEMY_KILLED += 1
			$AnimatedSprite2D.play("Spawn")			
			await get_tree().create_timer(0.5).timeout	
			queue_free()
			
	if isSpawning:
		$AnimatedSprite2D.play("Spawn")
		await get_tree().create_timer(.5).timeout
		isSpawning = false
	else:
		for body in attackRangeDetector.get_overlapping_bodies():
			if "Player" in body.name:
				enableAttack = true
	#
		if HEALTH_COUNT > 0:
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
				$AnimatedSprite2D.play("Idle")
			elif isHurting:
				$AnimatedSprite2D.play("Hurt")
			elif enableAttack:
				SPEED = 5
				$AnimatedSprite2D.play("Attack")
				
				if $AnimatedSprite2D.frame == 6 || $AnimatedSprite2D.frame == 7:
					sword.disabled = false					
				else:
					sword.disabled = true
					
			else:
				$AnimatedSprite2D.play("Walk")
				
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
		GLOBAL.SCORE += 10
		healthBar.value -= 20
		HEALTH_COUNT -= 1
		if HEALTH_COUNT <= 0:
			if not hurtAudio.playing:
				hurtAudio.play()
			else:
				hurtAudio.stop()
			enemy.disabled = true
			hitbox.disabled = true
			healthBar.visible = false
			velocity.x = 0
			$AnimatedSprite2D.play("Death")
			
			

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
