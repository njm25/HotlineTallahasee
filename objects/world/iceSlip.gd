extends Area2D

var _player = null
var prev_fric = 0.0  # Store player's previous friction value
@export var ice_friction = 0.01  # Friction on ice

func _ready():
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		prev_fric = _player.current_friction  # Store the current friction
		_player.current_friction = ice_friction  # Apply ice friction
		_player.is_sliding = true  # Mark the player as sliding
		
func _on_body_exited(other):
	if other == _player:
		if other is PlayerController:
			_player.current_friction = prev_fric  # Reset to previous friction
			_player.is_sliding = false  # Mark the player as no longer sliding
			
		_player = null
