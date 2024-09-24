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
		var player_inventory = _player.get_node("PlayerInventory")
		# Separate the assignment of the modifier dictionaries
		var weapon_add_mod = { "fire_rate": 0.2 }
		var weapon_mult_mod = { "recoil_strength": 2 }
		var weapon_modifiers = Modifier.new(weapon_add_mod, weapon_mult_mod)
		
		var player_add_mod = { "speed": 1000 }
		var player_mult_mod = { "friction": 0.8 }
		var player_modifiers = Modifier.new(player_add_mod, player_mult_mod)

		# Apply to player inventory and controller
		player_inventory.apply_modifier(weapon_modifiers)
		_player.apply_modifier(player_modifiers)
		
		
func _on_body_exited(other):
	if other == _player:
		if other is PlayerController:
			pass  # Mark the player as no longer sliding
		_weapon = null
		_player = null
