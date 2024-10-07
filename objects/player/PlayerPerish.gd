extends AnimatedSprite2D

# This function will be called when the node is added to the scene
func _ready():
	# Play the death animation
	play()
	# Connect the animation finished signal to set to the last frame
	connect("animation_looped", self._on_animation_finished)

# Function to keep the node at the last frame after the animation finishes
func _on_animation_finished():
	speed_scale  = 0
	frame = 14
