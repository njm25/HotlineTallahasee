extends Node

@export var health = 100
@export var player_inventory = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var pistol = Pistol.new()
	var toolgun = ToolGun.new()
	var testgun = TestGun.new()
	get_node("PlayerController/PlayerInventory").create_weapon(pistol, get_node("PlayerController"))
	get_node("PlayerController/PlayerInventory").create_weapon(toolgun, get_node("PlayerController"))
	get_node("PlayerController/PlayerInventory").create_weapon(testgun, get_node("PlayerController"))
	pass



func test_print():
	print("this works")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
