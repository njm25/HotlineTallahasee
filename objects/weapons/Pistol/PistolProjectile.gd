extends RigidBody2D

func _ready():
	connect("body_entered", self._on_body_entered)

# Signal handler for detecting body collisions
func _on_body_entered(body):
	var base_enemy = body.get_parent().get_parent()
	if base_enemy is Enemy:
		base_enemy.queue_free()
	if body is Map:
		print("yes")
	queue_free()  # Delete the projectile when a collision occurs
