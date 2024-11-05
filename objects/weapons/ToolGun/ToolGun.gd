extends 'res://objects/weapons/Weapon.gd'
class_name ToolGun

var enemies = ["Gremlin", "Slugmo", "Gromlin", "Mangler"]
var selected_enemy_index = 0
var _enemy_scene = null

func _init():
	fire_rate = 0
	accept_modifiers = false
	has_ammo = false
	super._init() 
	# Load the initial enemy
	_enemy_scene = load("res://objects/enemies/%s/%s.tscn" % [enemies[selected_enemy_index], enemies[selected_enemy_index]])

func shoot(player: PlayerController, mouse_pos):
	if _enemy_scene:
		var enemy_instance = _enemy_scene.instantiate()
		enemy_instance.global_position = mouse_pos
		player.get_parent().get_parent().get_parent().add_child(enemy_instance)

func cycle():
	selected_enemy_index += 1
	if selected_enemy_index >= enemies.size():
		selected_enemy_index = 0
	
	# Dynamically load the next enemy scene
	_enemy_scene = load("res://objects/enemies/%s/%s.tscn" % [enemies[selected_enemy_index], enemies[selected_enemy_index]])

func get_selected_enemy_type():
	return enemies[selected_enemy_index]

func get_gun_type():
	return "ToolGun"
