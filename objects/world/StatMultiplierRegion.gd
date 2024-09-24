extends Area2D

var _player = null
var _weapon = null
var prev_fire_rate = 0.0

func _ready():
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		_weapon = _player.get_node("PlayerInventory").current_weapon
		prev_fire_rate = _weapon.fire_rate
		_weapon.fire_rate = 0.1
		
		
func _on_body_exited(other):
	if other == _player:
		if other is PlayerController:
			_weapon.fire_rate = prev_fire_rate  # Mark the player as no longer sliding
		_weapon = null
		_player = null
