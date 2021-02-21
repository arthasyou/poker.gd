extends Control

const Utility = preload("res://Scripts/Utility.gd")

onready var _chips = $TotalPot/Chips
onready var _title = $TotalPot/Title

export (String) var title_text

func _ready() -> void:
	_title.text = title_text
	visible = false

func set_pot(value: int) -> void:
	_chips.text = Utility.Currency.get_currency(value)
	if value == 0:
		visible = false
	else:
		visible = true
