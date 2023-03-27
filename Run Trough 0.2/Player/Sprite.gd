extends Node2D

export var player_path : NodePath

var previous_frame_velocity := Vector2(0,0)
func _ready() -> void:
		print("Sprite.gd is missing player_path")
		set_process(false)
