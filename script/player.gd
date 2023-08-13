extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var swordAttack = get_node("Sword/CollisionShape2D")
@onready var sword = get_node("Sword")
@onready var hurtBox = get_node("Hurtbox/CollisionPolygon2D")
@onready var hurtBoxDetector = get_node("Hurtbox")
@onready var healthBar = get_node("/root/world/CanvasGroup/CanvasLayer2/Healthbar/ProgressBar")
@onready var shield = get_node("Shield")
@onready var display_size = get_viewport().get_visible_rect().size
@onready var GLOBAL = get_node("/root/Global")
@onready var swooshAudio = get_node("/root/world/SFX/sword_swoosh")
@onready var walkAudio = get_node("/root/world/SFX/walk")
@onready var slideAudio = get_node("/root/world/SFX/slide")
@onready var parryAudio = get_node("/root/world/SFX/parry")
var KNOCKBACK_FORCE = 300
var isAttacking = false
var isHurting = false
var isRolling = false
var isSliding = false
var cannotTurn = false
var isCrouching = false
var isCrouchAttack = false
var isShield = false
var canShield = true

func _physics_process(delta):
#	for area in hurtBoxDetector.get_overlapping_areas():
#		print("AAA ", area.name)

	if isShield:
		shield.visible = true
	else:
		shield.visible = false
	
	if self.position.x >= display_size.x:
		self.position.x = 0
	if self.position.x <= -10:
		self.position.x = display_size.x
		
	var direction = Input.get_axis("ui_left", "ui_right")
	handlePlayerInput(direction)
	
	if GLOBAL.HEALTH_COUNT > 0:
		if not is_on_floor():
			walkAudio.stop()
			velocity.y += gravity * delta
			if velocity.y < 0:
				animatedSprite.play("Jump")	
			else:
				animatedSprite.play("Fall")				
		
				
		if direction && !isAttacking && !cannotTurn && !isCrouchAttack:
			
			if is_on_floor():	
				if isCrouching:
					SPEED = 50
					animatedSprite.play("Crouch_Walk")
				else:
					SPEED = 300.0	
					if not walkAudio.playing:
						walkAudio.play()		
					animatedSprite.play("Run")
			velocity.x = direction * SPEED
			
			if velocity.x < 0:
				animatedSprite.flip_h = true
				swordAttack.position.x = -65
			else:
				animatedSprite.flip_h = false
				swordAttack.position.x = 0
		else:		
			walkAudio.stop()
			var moveTo = 0
			if isRolling && !isAttacking:
				cannotTurn = true
				animatedSprite.play("Roll")
				if animatedSprite.flip_h:
					moveTo = -302
				else:
					moveTo = 302
			elif isSliding && !isAttacking:
				if not slideAudio.playing:
					slideAudio.play()			
				cannotTurn = true
				animatedSprite.play("Slide")
				if animatedSprite.flip_h:
					moveTo = -302
				else:
					moveTo = 302
			elif is_on_floor():
				if isCrouchAttack:
					animatedSprite.play("Crouch_Attack")
				elif isAttacking:
					for body in sword.get_overlapping_areas():
						if "sword" in body.name:
							parryAudio.play()
					animatedSprite.play("Attack")
				elif isHurting:
					animatedSprite.play("Fall")
				elif isCrouching:
					animatedSprite.play("Crouch")
				else:
					animatedSprite.play("Idle")
			velocity.x = move_toward(velocity.x, moveTo, SPEED)
		move_and_slide()


func _on_animated_sprite_2d_animation_finished():
	isAttacking = false
	isCrouchAttack = false
	swordAttack.disabled = true
	cannotTurn = false
	
	if !GLOBAL.RESPAWN_PLAYER && GLOBAL.HEALTH_COUNT <= 0:
		healthBar.value = 100
		
	if GLOBAL.HEALTH_COUNT <= 0:
		GLOBAL.LIFE -= 1
		GLOBAL.RESPAWN_PLAYER = true
	
	if GLOBAL.HEALTH_COUNT <= 0 && GLOBAL.LIFE <= 0:
		self.queue_free()
	
func hurt_player(area, knockback_multiplier):
	if !isShield:
		isHurting = true
		if !hurtBox.disabled:
			healthBar.value -= 10
			GLOBAL.HEALTH_COUNT -= 1
			if GLOBAL.HEALTH_COUNT == 0:
				velocity.x = 0
				animatedSprite.play("Death")
			if area.global_position.x < self.global_position.x:
				velocity.x = KNOCKBACK_FORCE * knockback_multiplier
			else:
				velocity.x = -(KNOCKBACK_FORCE * knockback_multiplier)
		hurtBox.disabled = true
		move_and_slide()
		await get_tree().create_timer(0.25).timeout
		isHurting = false
		hurtBox.disabled = false
	else:
		parryAudio.play()

func _on_hurtbox_area_shape_entered(_area_rid, area, area_shape_index, _local_shape_index):
	var areaCollision = area.shape_owner_get_owner(area_shape_index)	
	if "sword" in area.name && !areaCollision.disabled:
		hurt_player(area, 3)


func _on_hurtbox_body_entered(body):
	if "Enemy" in body.name && body.HEALTH_COUNT > 0:
		hurt_player(body, 4.5)
		
func handlePlayerInput(direction):
#	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") and is_on_floor():
#		walkAudio.play()
#
#	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right") or isAttacking or isCrouching or isCrouchAttack or isRolling:
#		walkAudio.stop()
			
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() && !isAttacking:
		velocity.y = JUMP_VELOCITY
			
	if Input.is_action_just_pressed("attack") and is_on_floor():
		swooshAudio.play()
		if isCrouching:
			isCrouchAttack = true
		else:
			isAttacking = true
		swordAttack.disabled = false
		
	if Input.is_action_pressed("roll") and is_on_floor() and direction:
		isRolling = true
		cannotTurn = true
			
	if Input.is_action_just_released("roll"):
		await get_tree().create_timer(.5).timeout
		isRolling = false
		cannotTurn = false
			
	if Input.is_action_pressed("slide") and is_on_floor() and direction:
		isSliding = true
		cannotTurn = true
			
	if Input.is_action_just_released("slide"):
		await get_tree().create_timer(.5).timeout
		isSliding = false
		cannotTurn = false
		
	if Input.is_action_just_pressed("crouch"):
		isCrouching = true
		
	if Input.is_action_just_released("crouch"):
		isCrouching = false
		
	if Input.is_action_just_pressed("shield") and canShield:
		isShield = true
		$Timer.start()
		canShield = false
		await get_tree().create_timer(.5).timeout
		isShield = false

func _on_timer_timeout():
	canShield = true
