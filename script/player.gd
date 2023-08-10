extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
var isAttacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var swordAttack = get_node("Sword/CollisionShape2D")
@onready var hurtBox = get_node("Hurtbox/CollisionPolygon2D")
@onready var healthBar = get_node("Healthbar/ProgressBar")
@onready var display_size = get_viewport().get_visible_rect().size
var HEALTH_COUNT = 10
var KNOCKBACK_FORCE = 300
var isHurting = false
var isRolling = false
var isSliding = false
var cannotTurn = false

func _physics_process(delta):
#	print("VEL", velocity.x)
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y < 0:
			animatedSprite.play("Jump")	
		else:
			animatedSprite.play("Fall")				
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		isAttacking = true
		swordAttack.disabled = false
	
	if Input.is_action_just_pressed("roll") and is_on_floor():
		isRolling = true
		cannotTurn = true
		
	if Input.is_action_just_released("roll"):
		await get_tree().create_timer(.5).timeout
		isRolling = false
		cannotTurn = false
		
	if Input.is_action_just_pressed("slide") and is_on_floor():
		isSliding = true
		cannotTurn = true
		
	if Input.is_action_just_released("slide"):
		await get_tree().create_timer(.5).timeout
		isSliding = false
		cannotTurn = false
		
			
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction && !isAttacking:
		var currentDirection = direction
		if is_on_floor():
			if isRolling:
				animatedSprite.play("Roll")
			elif isSliding:
				animatedSprite.play("Slide")
			else:
				animatedSprite.play("Run")
		
		velocity.x = direction * SPEED
		
		if velocity.x < 0:
			animatedSprite.flip_h = true
			swordAttack.position.x = -69
		else:
			animatedSprite.flip_h = false
			swordAttack.position.x = 2
			
		if self.position.x >= display_size.x:
			self.position.x = 0
		if self.position.x <= -10:
			self.position.x = display_size.x
	else:
		if is_on_floor():
			if isAttacking:
				animatedSprite.play("Attack")		
			elif isHurting:
				animatedSprite.play("Fall")
			else:
				animatedSprite.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func _on_animated_sprite_2d_animation_finished():
	isAttacking = false
	swordAttack.disabled = true
#	isRolling = false
#	isSliding = false

func _on_hurtbox_body_entered(body):
	if "Enemy" in body.name:
		isHurting = true
		if !hurtBox.disabled:
			healthBar.value -= 10
			HEALTH_COUNT -= 1
			if HEALTH_COUNT == 0:
				self.queue_free()
			if body.position.x < self.position.x:
				velocity.x = KNOCKBACK_FORCE * 3
			else:
				velocity.x = -(KNOCKBACK_FORCE * 3)
		hurtBox.disabled = true
		move_and_slide()
		await get_tree().create_timer(0.1).timeout
		isHurting = false
		hurtBox.disabled = false

