extends AudioStreamPlayer

var Intro = preload("res://Assets/Audio/171 Voice Overs/OpeningScene.mp3")
var Boss1 = preload("res://Assets/Audio/171 Voice Overs/Boss Pt 1.mp3")
var Boss2 = preload("res://Assets/Audio/171 Voice Overs/Boss Pt 2.mp3")
signal boss_open

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_stream(Intro)
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_boss_trigger(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_stream(Boss1)
		play()
		await finished
		boss_open.emit()
		await get_tree().create_timer(1).timeout
		set_stream(Boss2)
		play()
