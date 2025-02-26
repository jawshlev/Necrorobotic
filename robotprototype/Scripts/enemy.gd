extends CharacterBody2D

@export var speed: float = 200.0
@export var follow_distance: float = 500.0  

var player: NodePath = null 

func _ready():
	if player == null:
		print("There is no player")

func _physics_process(delta: float) -> void:
	if not player:
		return

	var player_node = get_node_or_null(player)
	if not player_node:
		return

	var distance_to_player = global_position.distance_to(player_node.global_position)

	if distance_to_player <= follow_distance:
		var direction = (player_node.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
