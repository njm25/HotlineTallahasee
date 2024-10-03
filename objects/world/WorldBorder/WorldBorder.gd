extends Area2D
class_name WorldBorder




func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is Projectile:
		other.queue_free()
	
