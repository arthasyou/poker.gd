extends Node2D

const Utility = preload("res://Scripts/Utility.gd")
const Model = preload("res://Scripts/Model.gd")
const MyProto = preload("res://scripts/all_pb.gd")

onready var _hud = $ActorHUD
onready var _rest_timer = $RestTimer
onready var _card_spawner = $CardSpawner

var model:Model.ActorModel


func initialize(actor:Model.ActorModel, speed:int) -> void:
	model = actor
	set_property(speed)
	
func set_chips(value: int) -> void:
	model.chips = value
	_hud.set_chip(Utility.Currency.get_currency(model.chips))
	
func fold() -> void:
	model.state = MyProto.e_actor_state.FOLD
	_hud.set_pos(model.get_pos_text())
	clear_cards()

#func put_in_blind(value: int) -> void:
#	if model.reduce_chips(value):
#		_hud.set_chip(Utility.Currency.get_currency(model.chips))
#		GlobalSignals.emit_signal("actor_blind", get_parent().model.id, value)

func set_active(sec: int) -> void:
	_hud.set_rest_time(sec)
	if sec > 0: 
		_rest_timer.wait_time = sec
		start_reset_timer()


func clear_active() -> void:
	_hud.clear_timer()
	
# ==============================================================================

func set_property(speed: int) -> void:
	_hud.set_name(model.name)
	_hud.set_pos(model.get_pos_text())
	_hud.set_symbol("$")
	_hud.set_chip(Utility.Currency.get_currency(model.chips))
	_hud.set_max_rest_time(speed)
	_hud.set_rest_time(speed)
#	_rest_timer.wait_time = 30
	set_cards()
#	start_reset_timer()


func set_cards() -> void:
	if model.state == MyProto.e_actor_state.ACTIVE:
		if model.hands:
			_card_spawner.spawn_cards(model.hands)

func show_cards(hands: Array) -> void:
	model.hands = hands
	_card_spawner.clear_cards()
	_card_spawner.spawn_cards(model.hands)

func clear_cards() -> void:
	model.hands = []
	_card_spawner.clear_cards()

func set_state(state: int) -> void:
	model.state = state
	_hud.set_pos(model.get_pos_text())

func start_reset_timer() -> void:
#	_rest_timer.start()
	_hud.start_rest_timer()

# ==============================================================================

func _on_RestTimer_timeout() -> void:
	pass
