extends Area2D

const id = 0
const speed = 50
const jump = -50
const drain = 1

func _on_body_entered(body):
	if(body.is_in_group("Player")):
		#print(body.energy)
		body.energy = body.MAX_NRG
		
		queue_free()
