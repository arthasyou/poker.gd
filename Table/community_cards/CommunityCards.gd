extends Position2D

var _flop_cards: Array
var _turn_card
var _river_card

onready var _flop = $Flop
onready var _turn = $Turn
onready var _river = $River

# ==============================================================================

func set_cards(cards: Array) -> void:
	var l = len(cards)
	match l:
		3:
			set_flop_cards(cards)
		4:
			set_flop_cards(cards.slice(0,2))
			set_turn_cards(cards[3])
		5:
			set_flop_cards(cards.slice(0,2))
			set_turn_cards(cards[3])
			set_river_cards(cards[4])
	

func set_flop_cards(cards: Array) -> void:
	_flop_cards = cards
	_flop.spawn_cards(cards)

func set_turn_cards(card: String) -> void:
	_turn_card = card
	_turn.spawn_cards([card])

func set_river_cards(card: String) -> void:
	_river_card = card
	_river.spawn_cards([card])

func clear_cards() -> void:
	_flop_cards = []
	_turn_card = null
	_river_card = null
	
	_flop.clear_cards()
	_turn.clear_cards()
	_river.clear_cards()
	
# ==============================================================================
	




