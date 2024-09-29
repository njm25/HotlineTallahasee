extends Node2D
class_name CardManager

var current_weapon_name = ""
var inventory = null
var player = null
var cards = []  # This is now an array instead of a dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()
	inventory = player.get_node("PlayerInventory")
		
func add_card(card: Modifier):
	# Add card to the array
	cards.append(card)
	if card.type == "Weapon":
		inventory.apply_modifier(card)
	elif card.type == "Player":
		player.apply_modifier(card)

func remove_card(card: Modifier):
	# Ensure the card exists before removing
	if card in cards:
		cards.erase(card)  # Erase the card from the array
		if card.type == "Weapon":
			inventory.remove_modifier(card)
		elif card.type == "Player":
			player.remove_modifier(card)

func get_card_names() -> String:
	# Function to return a string of all card names for printing
	var card_names = ""
	for card in cards:
		card_names += card.card_name + "\n"
	return card_names
