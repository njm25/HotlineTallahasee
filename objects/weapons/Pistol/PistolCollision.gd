extends RigidBody2D

func _ready():
	connect("body_entered", self._on_body_entered)

# Signal handler for detecting body collisions
func _on_body_entered(body):
	if body.get_parent().get_parent() is Enemy:
		body.get_parent().queue_free()
	queue_free()  # Delete the projectile when a collision occurs
