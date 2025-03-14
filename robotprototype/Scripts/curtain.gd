extends Area2D

var player
var player_present :bool = false # checks if the player is currently in the area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player_present):
		enemy_immobilizer(false)
	else:
		enemy_immobilizer(true)


func enemy_immobilizer(toggle: bool):
	for agent in get_overlapping_bodies():
		if(agent.is_in_group("Enemy") and "immobile" in agent):
			agent.immobile = toggle

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		$MeshInstance2D.visible = false
		player_present = true

func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_present = false
