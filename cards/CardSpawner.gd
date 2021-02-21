extends Node2D

func spawn_cards(cards: Array) -> void:
	var list_of_position = get_children()
	for i in get_child_count():
		list_of_position[i-1].spawn_card(cards[i-1])

func clear_cards() -> void:
	for n in get_children():
		n.clear_card()
