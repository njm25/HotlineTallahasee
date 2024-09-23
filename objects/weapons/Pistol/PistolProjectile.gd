extends 'res://objects/weapons/Projectile.gd'
class_name PistolProjectile

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	max_bounces = 1
	
	super._init()  # Call parent _init()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
