extends CharacterBody2D

@export var target: Node2D
@export var speed := 12.0
@export var detect_radius := 80.0
@export var use_gravity := true
@export var bounce := false

enum States {
	PATROL,
	FOLLOW,
}

#var body: CharacterBody2D
var route: Curve2D
var state: States = States.PATROL
var point_idx := 1
var direction := 1

func _ready():
	route = get_parent().curve

func _physics_process(delta):
	var is_detecting = global_position.distance_to(target.global_position) < detect_radius
	
	match state:
		States.PATROL:
			
			var next_point = route.get_point_position(point_idx)
			
			# Curve2D.get_point_position() uses curve's local position
			if position.distance_to(route.get_point_position(point_idx)) < 1.0:
				point_idx += direction
				if bounce:
					if point_idx >= route.point_count or point_idx <= 0:
						direction *= -1
						point_idx += 2 * direction
						
				elif point_idx == route.point_count:
					point_idx = 0
			
			if use_gravity:
				velocity = Vector2(next_point.x - position.x, 0).normalized() * speed
			else:
				velocity = (next_point - position).normalized() * speed
			
			if is_detecting:
				state = States.FOLLOW
		States.FOLLOW:
			
			if use_gravity:
				velocity = Vector2(target.global_position.x - global_position.x, 0).normalized() * speed
			else:
				velocity = (target.global_position - global_position).normalized() * speed
			
			if not is_detecting:
				state = States.PATROL
				
	
	if use_gravity and not is_on_floor():
		velocity.y = 0.0
		velocity += get_gravity() 

	move_and_slide()
