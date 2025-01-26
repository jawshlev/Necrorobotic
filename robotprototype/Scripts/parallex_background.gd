extends Node2D

@onready var parallax_background: ParallaxBackground = $ParallaxBackground

const SCROLL_SPEED : float = 150.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	parallax_background.scroll_offset.x -= delta * SCROLL_SPEED
