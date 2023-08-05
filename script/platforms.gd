extends Node2D


# Called when the node enters the scene tree for the first time.
@onready var camera = get_node("../Player/Camera2D")
@onready var plat1 = get_node("1")
@onready var plat2 = get_node("2")
@onready var plat3 = get_node("3")
@onready var plat4 = get_node("4")
@onready var plat5 = get_node("5")
@onready var plat6 = get_node("6")
@onready var plat7 = get_node("7")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("tset",camera, plat1)
