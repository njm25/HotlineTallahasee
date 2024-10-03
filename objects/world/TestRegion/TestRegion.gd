extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		var player_inventory = _player.get_node("PlayerInventory")  # Ensure you're getting the correct node
		
		var pistol = Pistol.new()
		var toolgun = ToolGun.new()
		var testgun = TestGun.new()
		
		player_inventory.create_weapon(pistol, _player)
		player_inventory.create_weapon(toolgun, _player)
		player_inventory.create_weapon(testgun, _player)
