extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		
		var modifier = PlayerSpeed.new()
		
		_player.remove_modifier(modifier)
		
	
