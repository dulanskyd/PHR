extends KinematicBody2D
class_name Actor

export var speed: = Vector2(300.0, 1000.00)
export var gravity: = 4000.0

var velocity: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
