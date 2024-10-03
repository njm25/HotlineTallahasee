extends Camera2D

@export var smoothing_speed: float = 8.0  # Adjust this value to change smoothing speed

var target_position: Vector2 = Vector2.ZERO
var player: Node = null

func _ready() -> void:
	# Connect to the player_respawned signal
	var game_node = get_parent()  # Assuming the respawn logic is in the parent node
	game_node.connect("player_respawned", self._on_player_respawned)

func _process(delta: float) -> void:
	if player:
		# Update the target position
		target_position = player.global_position
		
		# Smoothly interpolate the camera's position towards the target position
		self.global_position = self.global_position.lerp(target_position, smoothing_speed * delta)

# Update the player when respawned
func _on_player_respawned(new_player):
	player = new_player
