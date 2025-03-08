extends Node2D

@onready var projectile = preload("res://Prefabs/bullet.tscn").instantiate()
@export var direction : float

func shoot_bullet(direction: float):
	print("instance of bullet")
	projectile.direction = direction
	add_child(projectile)
