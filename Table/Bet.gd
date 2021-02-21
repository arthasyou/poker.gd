extends Position2D

const Utility = preload("res://Scripts/Utility.gd")

onready var _chips = $C/Chips

func _ready() -> void:
	visible = false

func set_chips(value: int) -> void:
	_chips.text = Utility.Currency.get_currency(value)
	if value == 0:
		visible = false
	else:
		visible = true

