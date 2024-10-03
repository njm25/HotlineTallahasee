extends Area2D

var _player = null

func _ready():
	connect("body_entered", self._on_body_entered)

func _on_body_entered(other):
	if other is PlayerController:
		_player = other
		var card_manager = _player.get_node("CardManager")

		# Check if there are any cards in the card_manager
		if card_manager.cards.size() > 0:
			# If the array is not empty, remove the last card
			var last_card = card_manager.cards[-1]  # Access the last card in the array
			card_manager.remove_card(last_card)
