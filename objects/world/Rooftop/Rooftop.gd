extends Area2D


var player
var player_is_dead: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body is PlayerController:
		player = body
		var roof = get_node("ColorRect")
		if not player.is_connected("player_died", self._on_player_death):
			player.connect("player_died", self._on_player_death)
		var tween = create_tween()
		tween.tween_property(roof, "modulate:a", 0.0, 0.2)  # Animate alpha to 0 over 1 second

func _on_player_death():
	player_is_dead = true

func _on_body_exited(body):
	if !player_is_dead:
		if body is PlayerController:
			var roof = get_node("ColorRect")
			# Create a tween and animate the modulate alpha (fade in)
			var tween = create_tween()
			tween.tween_property(roof, "modulate:a", 1.0, 0.2)  # Animate alpha to 1 over 1 second
