extends Area2D

var _player = null
var prev_fric = 0.0
@export var ice_friction = 0.01
func _ready():
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)

func _on_body_entered(other):
	if other is CharacterBody2D:
		_player = other
		prev_fric = _player.friction
		_player.friction = ice_friction

func _on_body_exited(other):
	if (other == _player):
		if other is CharacterBody2D:
			_player.friction = prev_fric
		_player = null
