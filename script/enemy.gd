extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var player = get_node("/root/world/Player")
var SPEED = 50.0
const stop_chance = 0.5
var move_timer = 3.0
var time_since_move = 0.0
var current_direction = 1
var isPlayerDetected = false

func _ready():
	time_since_move = move_timer
	current_direction = randf_range(-1, 1)

func _physics_process(delta):
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
	velocity.x = current_direction * SPEED
	
	if velocity.x == 0:
		sprite.play("Idle")
	else:
		sprite.play("Walk")
	
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	move_and_slide()
	


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		isPlayerDetected = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		isPlayerDetected = false
