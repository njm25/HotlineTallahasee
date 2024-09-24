extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		
		var player_inventory = other.get_node("PlayerInventory")
		player_inventory.restore_defaults()
	
