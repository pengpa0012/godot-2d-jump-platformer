extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	pass


func _on_area_2d_body_entered(body):
	print(body.name)
