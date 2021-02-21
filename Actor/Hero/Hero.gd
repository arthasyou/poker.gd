extends "res://actor/Actor.gd"

signal set_gui_chips(min_v, max_v)
signal set_gui_min_chips(value)
signal set_gui_max_chips(value)


func _ready() -> void:
	var gui = get_tree().get_nodes_in_group("gui")[0]
	connect("set_gui_chips", gui, "_handle_chips")
	connect("set_gui_min_chips", gui, "_handle_min_chips")
	connect("set_gui_max_chips", gui, "_handle_max_chips")


func _handle_bet(text: String):
	GlobalSignals.bet(1, text)
	
func set_slider_chips(min_v: int) -> void:
	emit_signal("set_gui_chips", min_v, model.chips)

func set_active(sec: int) -> void:
	_hud.set_rest_time(sec)
	if sec > 0: 
		_rest_timer.wait_time = sec
		start_reset_timer()
	emit_signal("set_gui_max_chips", model.chips)


