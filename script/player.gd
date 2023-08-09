extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
var isAttacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var swordAttack = get_node("Sword/CollisionShape2D")
@onready var display_size = get_viewport().get_visible_rect().size

func _physics_process(delta):
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
			
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction && !isAttacking:
		if is_on_floor():
			animatedSprite.play("Run")		
		velocity.x = direction * SPEED
		
		if velocity.x == -300:
			animatedSprite.flip_h = true
			swordAttack.position.x = -74
		else:
			animatedSprite.flip_h = false
			swordAttack.position.x = 6
		if self.position.x >= display_size.x:
			self.position.x = 0
		if self.position.x <= -10:
			self.position.x = display_size.x
	else:
		if is_on_floor():
			if isAttacking:
				animatedSprite.play("Attack")		
			else:
				animatedSprite.play("Idle")		
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func _on_animated_sprite_2d_animation_finished():
	isAttacking = false
	swordAttack.disabled = true	


func _on_area_2d_body_entered(body):
	if "Enemy" in body.name:
		var enemy = body.get_node("AnimatedSprite2D")
		enemy.play("Hurt")
#		enemy.queue_free()


func _on_timer_timeout():
	print("ded")
	timer.stop()
#	body.queue_free()
	
