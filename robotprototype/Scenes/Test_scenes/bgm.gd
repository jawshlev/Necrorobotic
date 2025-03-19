extends AudioStreamPlayer

var BGMBoss = preload("res://Assets/Audio/bosssoundscape.mp3")
var BGMFactory = preload("res://Assets/Audio/factorysoundscape.mp3")
var BGMSewer = preload("res://Assets/Audio/sewersoundscape.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_boss_trigger(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_stream(BGMBoss)
		play()
