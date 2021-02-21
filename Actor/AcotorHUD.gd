extends Control


onready var _name = $ColorRect/VC/VC/Property/NP/CC/Name
onready var _pos = $ColorRect/VC/VC/Property/NP/CC2/Pos
onready var _symbol = $ColorRect/VC/VC/Property/SA/CC/Symbol
onready var _chip = $ColorRect/VC/VC/Property/SA/CC/Chip
onready var _time_bar = $ColorRect/VC/VC/TimeBar
onready var tween = $ColorRect/VC/VC/Tween

const safety_color = Color("#30d355")
const danger_color = Color("#ff1744")


func set_name(value: String) -> void:
	_name.text = value

func set_pos(value: String) -> void:
	_pos.text = value

func set_symbol(value: String) -> void:
	_symbol.text = value

func set_chip(value: String) -> void:
	_chip.text = value

func set_max_rest_time(value: int) -> void:
	_time_bar.max_value = value

func set_rest_time(value: int) -> void:
	_time_bar.value = value


func start_rest_timer() -> void:
	var r = 0x30 - 0xff
	var g = 0xd3 - 0x17
	var b = 0x55 - 0x44

	var r1 = int(r / _time_bar.max_value * _time_bar.value) + 0xff
	var g1 = int(g / _time_bar.max_value * _time_bar.value) + 0x17
	var b1 = int(b / _time_bar.max_value * _time_bar.value) + 0x44

	var format_string = "#%x%x%x" % [r1,g1,b1]
	var current_color = Color(format_string)
	
	var bar_style = _time_bar.get("custom_styles/fg")
	tween.interpolate_property(_time_bar, "value", _time_bar.value, 0, _time_bar.value, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(bar_style, "bg_color", current_color, danger_color, _time_bar.value, Tween.TRANS_LINEAR, Tween.EASE_IN)  
	
	tween.start()

func clear_timer() -> void:
	tween.stop_all()
	_time_bar.value = 0
