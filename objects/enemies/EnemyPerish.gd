extends AnimatedSprite2D

# This function will be called when the node is added to the scene
func _ready():
	# Play the death animation
	play()
	# Connect the animation finished signal to queue_free
	connect("animation_looped", self._on_animation_finished)

# Function to remove the node after the animation finishes
func _on_animation_finished():
	queue_free()
