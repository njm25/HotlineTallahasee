extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		var card_manager = _player.get_node("CardManager")
		
		
		var modifier = PlayerSpeed.new()
		
		card_manager.add_card(modifier)
