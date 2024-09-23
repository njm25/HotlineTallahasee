extends 'res://objects/weapons/Weapon.gd'
class_name ToolGun

var _gremlin = preload("res://objects/enemies/Gremlin/Gremlin.tscn")

func _init():
	fire_rate = 0
	
	super._init() 

func _ready():
	pass 
	
func new(this):
	pass

func shoot(player: PlayerController, mouse_pos):
	var gremlin_instance = _gremlin.instantiate()
	gremlin_instance.global_position = mouse_pos
	player.get_parent().add_child(gremlin_instance)
	pass

func get_gun_type():
	return "ToolGun"

func _process(delta: float) -> void:
	pass
