extends CharacterBody2D

@export var speed: float = 200.0
@export var follow_distance: float = 500.0  # Distance at which the enemy starts following the player

var player: NodePath = null  # Assign the player's node path in the editor

func _ready():
    if player == null:
        print("Player node path not set. Please assign it in the editor.")

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
