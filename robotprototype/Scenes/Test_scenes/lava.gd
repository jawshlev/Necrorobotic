extends Area2D

const contact_damage = 25
var player

func _init():
	player = $Player

func _physics_process(delta: float) -> void:
	if player and get_overlapping_bodies().has(player):
		player.hurt(contact_damage)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		var wait_time = Timer.new()
		wait_time.start(0.5)
		if(wait_time.is_stopped()):
			print(wait_time.time_left)
		
		
