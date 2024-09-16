extends Node

@export var health = 100
@export var player_inventory = []
# Called when the node enters the scene tree for the first time.
func _ready():
	player_inventory = PlayerInventory.new()
	var weapon = Pistol.new()
	player_inventory.switch_weapon(weapon, self)

	
	




func test_print():
	print("this works")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
