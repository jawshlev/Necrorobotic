extends Sprite2D

# Variables to control the oscillation
var amplitude: float = 2  # Height of the jump
var speed: float = 10       # Speed of the oscillation

# Store the initial position of the sprite
var initial_position: Vector2

func _ready():
	# Save the initial position of the sprite when the game starts
	initial_position = position

func _process(delta):
	# Use a sine function to oscillate the y position
	print(position.y)
	position.y = initial_position.y + amplitude * sin(speed * global_position.x + (Time.get_unix_time_from_system()*1000) * 0.001)
