extends Node

@export var max_health: int = 100
var current_health: int = max_health

func take_damage(amount: int) -> void:
    current_health -= amount
    if current_health <= 0:
        die()

func die() -> void:
    print("debug: enemy killed")
    queue_free()
