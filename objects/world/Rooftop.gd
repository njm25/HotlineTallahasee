extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body is PlayerController:
		var roof = get_node("ColorRect")
		# Create a tween and animate the modulate alpha (fade out)
		var tween = create_tween()
		tween.tween_property(roof, "modulate:a", 0.0, 0.2)  # Animate alpha to 0 over 1 second

func _on_body_exited(body):
	if body is PlayerController:
		var roof = get_node("ColorRect")
		# Create a tween and animate the modulate alpha (fade in)
		var tween = create_tween()
		tween.tween_property(roof, "modulate:a", 1.0, 0.2)  # Animate alpha to 1 over 1 second
