extends Position2D

export (int) var sn = 1

const Model = preload("res://Scripts/Model.gd")
const Hero = preload("res://actor/hero/Hero.tscn")
const Opponent = preload("res://actor/opponent/Opponent.tscn")
const MyProto = preload("res://scripts/all_pb.gd")

onready var sit_down = $SitDown

var model:Model.SeatModel
var _actor

func initialize(seat:Model.SeatModel, speed:int) -> void:
	model = seat
	match model.actor_type:
		MyProto.e_actor_type.HERO:
			actor_sit_down(Hero, model.actor, speed)
		MyProto.e_actor_type.OPPONENT:
			actor_sit_down(Opponent, model.actor, speed)

func set_pos(pos: int) -> void:
	get_child(1).set_pos(pos)

func put_in_blind(value: int) -> void:
	get_child(1).put_in_blind(value)

func set_cards() -> void:
	get_child(1).set_cards()

func show_cards(hands) -> void:
	get_child(1).show_cards(hands)
	
func set_active(sec) -> void:
	get_child(1).set_active(sec)

func set_state(state) -> void:
	get_child(1).set_state(state)

func _on_Button_button_down() -> void:
	var data = MyProto.m_2002_tos.new()
	data.set_table_id(2)
	data.set_seat_id(sn)
	Ws.send_data(2002, data)

func actor_sit_down(type, actor, speed) -> void:
	sit_down.visible = false
	_actor = type.instance()
	add_child(_actor)
	_actor.initialize(actor, speed)
	_actor.position = Vector2.ZERO

func fold() -> void:
	get_child(1).fold()
