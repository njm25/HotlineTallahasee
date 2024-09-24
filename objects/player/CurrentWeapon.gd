extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_wep(weapon):
	get_node(weapon).set_visible(true)

func clear_wep(weapon):
	get_node(weapon).set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
