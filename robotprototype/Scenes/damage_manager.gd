extends Node

var invincible = false
var in_hurtbox = false
var contact_damage = 0
const iframes = 1 #Number of seconds player is invincible after hit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(in_hurtbox):
		hurt(contact_damage)

func hurt(amount):
	if(!invincible):
		health -= amount
		take_damage.emit(amount)
		invincible = true
		get_tree().create_timer(1).timeout.connect(func(): invincible = false)
		
