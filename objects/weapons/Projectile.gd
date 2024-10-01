extends CharacterBody2D
class_name Projectile

var bounces = 0
var max_bounces = 0  # Maximum number of bounces
var damage = 0
var knockback_force = 100  # Knockback force magnitude
var can_damage_player = false

func set_max_bounces(_max_bounces):
	max_bounces = _max_bounces

func set_damage(_damage):
	damage = _damage

func set_knockback_force(_force):
	knockback_force = _force

func _init():
	pass

func _physics_process(delta):
	# Move the projectile and check for collisions
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		# Handle collision with Enemy
		if collider is Enemy:
			collider.damage(damage)  # Apply damage to the enemy
			apply_knockback(collider)  # Apply knockback to the enemy
			queue_free()  # Remove the projectile

		if collider is PlayerController:
			if can_damage_player:
				collider.damage(damage)	
				apply_knockback(collider)  # Apply knockback to the player
			queue_free()  # Remove the projectile

		if collider is Projectile:
			collider.queue_free()  # Remove the other projectile
			queue_free()  # Remove the projectile

		# Handle collision with walls (e.g., Map) and bounce
		if collider is Map:
			handle_bounce(collision)
			
	# Rotate the projectile based on its velocity direction
	rotation = velocity.angle()

func handle_bounce(collision):
	# Check if the projectile has bounced too many times
	if bounces >= max_bounces:
		queue_free()  # Remove the projectile if max bounces is reached
	else:
		# Increment the bounce counter
		bounces += 1

		# Get the normal of the collision and reflect the velocity
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)  # Reflect velocity based on the collision normal

func apply_knockback(collider):
	# Apply knockback force in the direction of the projectile's velocity
	var direction = velocity.normalized()
	var knockback_vector = direction * knockback_force

	# Check if the collider has a method to apply force (such as a player or enemy)
	if collider.has_method("apply_impulse"):
		collider.apply_impulse(knockback_vector)
