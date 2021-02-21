extends Control

const MyProto = preload("res://scripts/all_pb.gd")

func _ready():
	pass


func _on_Button_pressed():
	var data = MyProto.m_1001_tos.new()
	data.set_id("1")
	Ws.send_data(1001, data)
#	data.free()


func _on_Button2_pressed():
	var data = MyProto.m_2000_tos.new()
	data.set_table_id(1)
	Ws.send_data(2000, data)
#	var data = Store.get_proto(1001)
#	print(data.get_flag())
