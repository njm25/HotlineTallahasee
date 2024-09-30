extends Camera2D

@export var smoothing_speed: float = 12.0  # Adjust this value to change smoothing speed

var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var player = get_parent().get_node("Player/Player/PlayerController")
	
	# Update the target position
	target_position = player.global_position
	
	# Smoothly interpolate the camera's position towards the target position
	self.global_position = self.global_position.lerp(target_position, smoothing_speed * delta)
