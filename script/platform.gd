extends StaticBody2D


# Called when the node enters the scene tree for the first time.
@onready var platform = $Player
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(platform)
