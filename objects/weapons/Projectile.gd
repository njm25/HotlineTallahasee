extends CharacterBody2D
class_name Projectile

var bounces = 0
@export var max_bounces = 0  # Maximum number of bounces

func _init():
	pass

func _physics_process(delta):
	# Move the projectile and check for collisions
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		# Handle collision with Enemy
		if collider is Enemy:
			collider.queue_free()  # Remove the enemy
			queue_free()  # Remove the projectile

		if collider is PlayerController:
			queue_free()  # Remove the projectile

		if collider is Projectile:
			collider.queue_free()  # Remove the enemy
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
