extends CanvasLayer

const Utility = preload("res://Scripts/Utility.gd")
const MyProto = preload("res://scripts/all_pb.gd")

onready var chip = $Control/MC/HC/VC2/HC2/Chip
onready var slider = $Control/MC/HC/VC2/HC2/HC/HSlider
onready var bets = $Control/MC/HC/VC/Bets
onready var bet_raise = $Control/MC/HC/VC/HC2/BetRaise

var _hero_seat = 1
var table_id: int

func _ready() -> void:
	_initialize_bets()
	
func init_table_id(id: int) -> void:
	table_id = id

func init_slider_step(step: int) -> void:
	slider.min_value = step
	slider.step = step

func _initialize_bets() -> void:
	for bet in bets.get_children():
		bet.text = Utility.Bet.get_bet_text(Store.get_settings(bet.name)) 
	

func _on_HSlider_value_changed(value: float) -> void:
	chip.text = Utility.Currency.get_currency(value)
	bet_raise.text = "Raise To " + Utility.Currency.get_currency(value)


func _on_Chip_text_entered(new_text: String) -> void:
	var value = float(new_text)
	if value > slider.max_value:
		value = slider.max_value
	slider.value = value


func _on_Chip_focus_entered() -> void:
	chip.text = str(slider.value)


func _on_Chip_focus_exited() -> void:
	pass # Replace with function body.


func _on_bet2_pressed() -> void:
	var model = get_parent().model
	print(model.total_pot)
#	var value = get_parent().get_total_pot() * 0.5
#	if value > slider.max_value:
#		value = slider.max_value
#	slider.value = value

func _handle_min_chips(value: int) -> void:
	slider.min_value = value
	slider.value = slider.min_value

func _handle_max_chips(value: int) -> void:
	slider.max_value = value
	slider.value = slider.min_value

func _handle_chips(min_v: int, max_v: int) -> void:
	slider.min_value = min_v
	slider.max_value = max_v
	slider.value = slider.min_value
	

func _on_bet_val_pressed(id: int) -> void:
	var text = bets.get_child(id).text
	var percent = Utility.Bet.get_bet_val(text)
	var v: int = 0
	if percent == 0:
		v = slider.min_value
	elif percent == 999:
		v = slider.max_value
	else:
		v = int( get_parent().model.total_pot * percent)
	slider.value = v
	
	


func _on_Button_pressed() -> void:
	var data = MyProto.m_1001_tos.new()
	data.set_id(1)
	Ws.send_data(1001, data)


func _on_Button2_pressed() -> void:
	var data = MyProto.m_2000_tos.new()
	data.set_table_id(table_id)
	Ws.send_data(2000, data)


func _on_Ready_pressed() -> void:
	var data = MyProto.m_2003_tos.new()
	data.set_table_id(table_id)
	Ws.send_data(2003, data)


func _on_Fold_pressed() -> void:
	var data = MyProto.m_2011_tos.new()
	data.set_table_id(table_id)
	Ws.send_data(2011, data)


func _on_CheckCall_pressed() -> void:
	var data = MyProto.m_2012_tos.new()
	data.set_table_id(table_id)
	Ws.send_data(2012, data)


func _on_BetRaise_pressed() -> void:
	var data = MyProto.m_2013_tos.new()
	data.set_table_id(table_id)
	data.set_chips(slider.value)
	Ws.send_data(2013, data)


func _on_Minus_pressed() -> void:
	slider.value -= slider.step


func _on_Plus_pressed() -> void:
	slider.value += slider.step
