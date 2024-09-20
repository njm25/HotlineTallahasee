extends 'res://objects/weapons/Weapon.gd'
class_name ToolGun

var _enemy = preload("res://objects/enemy/Enemy.tscn")

func _init():
	pass 

func _ready():
	pass 
	
func new(this):
	pass

func shoot(player: PlayerController, mouse_pos):
	var enemy_instance = _enemy.instantiate()
	enemy_instance.global_position = mouse_pos
	player.get_parent().add_child(enemy_instance)
	pass

func get_gun_type():
	return "ToolGun"

func _process(delta: float) -> void:
	pass
