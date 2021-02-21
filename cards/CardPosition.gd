extends Position2D

const path = "res://cards/suit/"
const suffix = ".tscn"
const spade = "spade/"
const heart = "heart/"
const diamond = "diamond/"
const club = "club/"

var _instance = null

func spawn_card(card: String) -> void:
	clear_card()
	var suit = card[0]
	var full_path: String
	if suit == "S":
		full_path = path + spade + card + suffix
	elif suit == "H":
		full_path = path + heart + card + suffix
	elif suit == "D":
		full_path = path + diamond + card + suffix
	elif suit == "C":
		full_path = path + club + card + suffix
	else:
		full_path = "res://cards/CardBack.tscn"
	
	var card_scence = load(full_path)
	_instance = card_scence.instance()
	add_child(_instance)
	_instance.position = Vector2.ZERO
	
func clear_card() -> void:
	if _instance:
		_instance.queue_free()
		_instance = null
#	print(_instance)
	
