extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		var player_inventory = _player.get_node("PlayerInventory")
		
		var modifier = WeaponAddMaxBounce.new()
		
		player_inventory.apply_modifier(modifier)
		
		
