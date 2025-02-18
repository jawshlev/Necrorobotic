extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 800.0
@export var sprite: Sprite2D
@export var start_flipped: bool = false
@export var ray_length: float = 10.0  
@export var ray_forward_offset: float = 5.0  

const contact_damage = 5	
const knockback = 200
const energy = 5
var health = 20
signal on_death

var direction: int = 1

func _ready():
	await get_tree().process_frame
	sprite = $CollisionShape2D/Sprite2D
	if sprite:
		sprite.flip_h = start_flipped

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	if is_on_wall() or !is_ground_ahead():
		flip_direction()
	velocity.x = direction * speed
	move_and_slide()

func is_ground_ahead() -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray_start = global_position + Vector2(direction * ray_forward_offset, 2)
	var ray_end = ray_start + Vector2(0, ray_length)
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 1  
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.has("collider")

func flip_direction():
	direction *= -1
	if sprite:
		sprite.flip_h = not sprite.flip_h

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var knockback_directional = knockback
		if body.global_position.x <= global_position.x:
			knockback_directional *= -1
		body.enter_hurtbox(contact_damage, knockback_directional)
		if is_player_in_front(body):
			flip_direction()

func is_player_in_front(player: Node2D) -> bool:
	var player_left = player.global_position.x < global_position.x and direction == -1
	var player_right = player.global_position.x > global_position.x and direction == 1
	return player_left or player_right

func take_damage(damage, _knockback):
	health -= damage
	if health <= 0:
		on_death.emit(energy)
		queue_free()
