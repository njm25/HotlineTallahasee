extends Node

@export var health = 100
@export var player_inventory = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var player_inventory = get_node("PlayerController/PlayerInventory")
	var player = get_node("PlayerController")
	var pistol = Pistol.new()
	var toolgun = ToolGun.new()
	var testgun = TestGun.new()
	
	player_inventory.create_weapon(pistol, player)
	player_inventory.create_weapon(toolgun, player)
	player_inventory.create_weapon(testgun, player)
	
	
	
	pass

func test_print():
	print("this works")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
