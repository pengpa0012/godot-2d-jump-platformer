extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var player = get_node("/root/world/Player")
@onready var display_size = get_viewport().get_visible_rect().size
@onready var healthBar = get_node("Healthbar/ProgressBar")
@onready var sword = get_node("Detectors/sword/CollisionShape2D")
@onready var attackRangeDetector = get_node("Detectors/attackRange")
@onready var GLOBAL = get_node("/root/Global")
var SPEED = 50.0
const stop_chance = 0.5
var move_timer = 3.0
var time_since_move = 0.0
var current_direction = 1
var isPlayerDetected = false
var isHurting = false
var HEALTH_COUNT = 5
var enableAttack = false

func _ready():
	time_since_move = move_timer
	current_direction = randf_range(-1, 1)

func _physics_process(delta):
#	for area in attackRangeDetector.get_overlapping_areas():
#		if "Hurtbox" in area.name && !sprite.is_playing():
#			enableAttack = true
#		else:
#			enableAttack = false
#
	print(HEALTH_COUNT)
	if HEALTH_COUNT != 0:
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
			sprite.play("Idle")
		elif isHurting:
			sprite.play("Hurt")
		elif enableAttack:
			SPEED = 5
			sprite.play("Attack")
			if sprite.frame == 4 || sprite.frame == 8:
				sword.disabled = false
			else:
				sword.disabled = true
				
		else:
			sprite.play("Walk")
			
		if current_direction < 0:
			sword.position.x = -40
			sprite.flip_h = true
		else:
			sword.position.x = 40
			sprite.flip_h = false
			
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
		if HEALTH_COUNT == 0:
			velocity.x = 0
			sprite.play("Death")

func _on_hitbox_area_exited(area):
	if area.name == "Sword":
		isHurting = false

func _on_visible_on_screen_enabler_2d_screen_exited():
	if is_instance_valid(player):
		if player.position.y < self.position.y:
			self.position.y -= display_size.y
		else:
			self.position.y += display_size.y
		self.position.x = randf_range(0, display_size.x)
	
func _on_attack_range_body_entered(body):
	if body.name == "Player":
		enableAttack = true

func _on_animated_sprite_2d_animation_finished():
	sword.disabled = true
	enableAttack = false
	if HEALTH_COUNT == 0:
		self.queue_free()

func _on_attack_range_body_exited(body):
	if !sprite.is_playing():
		enableAttack = false
		sword.disabled = true


