extends 'res://objects/weapons/Projectile.gd'


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init():
	can_damage_player = true
	can_damage_enemy = false
	super._init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
