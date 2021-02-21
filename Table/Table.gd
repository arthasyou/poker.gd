extends Node2D

const Model = preload("res://Scripts/Model.gd")
const Utility = preload("res://Scripts/Utility.gd")
const MyProto = preload("res://scripts/all_pb.gd")

onready var pot = $Pot
onready var community_cards = $CommunityCards
onready var seats = $Seats
onready var bets = $BetOfSeats
onready var timer = $BettingTimer
onready var gui = $GUI

var model:Model.TableModel

var hero_seat:int = 0
var _cards:Array = []
var active_seats:Array = []
var last_btn_seat = 0
var active_pos:Array = []


#func _init() -> void:
#	model = Model.TableModel.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var _ignore
	
	_ignore = GlobalSignals.connect("m_2000_toc", self, "_handle_m_2000_toc")
	
	_ignore = GlobalSignals.connect("m_2002_toc", self, "_handle_m_2002_toc")
	
	
	_ignore = GlobalSignals.connect("m_2010_toc", self, "_handle_m_2010_toc")
#	_ignore = GlobalSignals.connect("m_2011_toc", self, "_handle_m_2011_toc")
#	_ignore = GlobalSignals.connect("m_2012_toc", self, "_handle_m_2012_toc")
#	_ignore = GlobalSignals.connect("m_2013_toc", self, "_handle_m_2013_toc")
	_ignore = GlobalSignals.connect("m_2029_toc", self, "_handle_m_2029_toc")
	
	_ignore = GlobalSignals.connect("m_2021_toc", self, "_handle_m_2021_toc")
	_ignore = GlobalSignals.connect("m_2022_toc", self, "_handle_m_2022_toc")
	_ignore = GlobalSignals.connect("m_2023_toc", self, "_handle_m_2023_toc")
	_ignore = GlobalSignals.connect("m_2024_toc", self, "_handle_m_2024_toc")
	_ignore = GlobalSignals.connect("m_2025_toc", self, "_handle_m_2025_toc")
	_ignore = GlobalSignals.connect("m_2026_toc", self, "_handle_m_2026_toc")
	_ignore = GlobalSignals.connect("m_2027_toc", self, "_handle_m_2027_toc")
	_ignore = GlobalSignals.connect("m_2028_toc", self, "_handle_m_2028_toc")
	
	_ignore = GlobalSignals.connect("m_2030_toc", self, "_handle_m_2030_toc")
#	_clear_seats()


# ==============================================================================
# handle_signal
# ==============================================================================

# ------------------------------------------------------------------------------
# handle_proto

# init_table
func _handle_m_2000_toc(proto) -> void:
	model = Model.Model2000.new(proto).info
	_initialize()

# actor active
func _handle_m_2010_toc(proto) -> void:
	var seat_id = Model.Model2010.new(proto).seat_id
	var sn = _get_seat_scene_sn(seat_id)
	seats.get_child(sn).set_active(model.speed)
	
# actor action
func _handle_m_2029_toc(proto) -> void:
	var m = Model.Model2029.new(proto)
	_actor_action(m)

func _actor_action(m: Model.Model2029) -> void:
	var sn:int = _get_seat_scene_sn(m.seat_id)
	seats.get_child(sn).get_child(1).clear_active()
	match m.action_type:
		MyProto.e_action_type.FOLD:
			_fold(m.seat_id)
		MyProto.e_action_type.CHECK:
			_check(m.seat_id)
		MyProto.e_action_type.CALL:
			_call(m)
		MyProto.e_action_type.BET:
			_bet(m)
		MyProto.e_action_type.RAISE:
			_raise(m)
	

# fold
func _fold(seat_id: int) -> void:
	var sn:int = _get_seat_scene_sn(seat_id)
	seats.get_child(sn).get_child(1).fold()

# check
func _check(seat_id: int) -> void:
	pass

# call
func _call(m: Model.Model2029) -> void:
	_update_total_pot(m.total_pot)
	_update_action_seat(m)

# bet
func _bet(m: Model.Model2029) -> void:
	_update_total_pot(m.total_pot)
	_update_action_seat(m)

# raise
func _raise(m: Model.Model2029) -> void:
	_update_total_pot(m.total_pot)
	_update_action_seat(m)

func _update_action_seat(m: Model.Model2029) -> void:
	var sn:int = _get_seat_scene_sn(m.seat_id)
	seats.get_child(sn).get_child(1).set_chips(m.chips)
	bets.get_child(sn).set_chips(m.pot)
	
#	var sn:int = _get_seat_scene_sn(seat_id)
#	seats.get_child(sn).get_child(1).fold()


# flop cards
func _handle_m_2021_toc(proto) -> void:
	model.community_cards = Model.Model2021.new(proto).cards
	_init_community_cards()

# turn or reiver card
func _handle_m_2022_toc(proto) -> void:
	model.community_cards.push_back(Model.Model2022.new(proto).card)
	_init_community_cards()
	
# end of round
func _handle_m_2023_toc(proto) -> void:
	var m = Model.Model2023.new(proto)
	model.side_pot = m.sides
	_update_current_pot(m.current_pot)
#	model.current_pot = m.current_pot
	_update_seat_chips(m.seats_chips)
	
# put in blind
func _handle_m_2024_toc(proto) -> void:
	var m = Model.Model2024.new(proto)
	_update_total_pot(m.total_pot)
	_update_current_pot(m.current_pot)
	_update_seat_chips(m.seats_chips)

# show hand
func _handle_m_2025_toc(proto) -> void:
	var hands = Model.Model2025.new(proto).hands
	_show_hands(hands)

# win pot
func _handle_m_2026_toc(proto) -> void:
	var items = Model.Model2026.new(proto).seats
	_actor_win(items)

# player seat
func _handle_m_2002_toc(proto) -> void:
	var seat = Model.Model2002.new(proto).seat
	_hero_sit_down(seat)

# player seat
func _handle_m_2027_toc(proto) -> void:
	var seat = Model.Model2027.new(proto).seat
	_opponent_sit_down(seat)

# actor state update
func _handle_m_2028_toc(proto) -> void:
	var seat_state = Model.Model2028.new(proto).seat_state
	_update_seat_state(seat_state)


# ready state
func _handle_m_2030_toc(proto) -> void:
	var m = Model.Model2030.new(proto)
	_clear_table()
	model.state = MyProto.e_table_state.ready
	model.seats = m.seats
	model.total_pot = m.total_pot
	model.current_pot = m.current_pot
	_init_seats()
	_init_pot()

# ==============================================================================
# internal
# ==============================================================================

# ------------------------------------------------------------------------------
# initilalize

func _initialize() -> void:
	_init_seats()
	_init_pot()
	_init_community_cards()
	_init_active_seat()
	_init_gui()


func _init_seats() -> void:
	for seat in model.seats:
		var sn:int = _get_seat_scene_sn(seat.id)
		seats.get_child(sn).initialize(seat, model.speed)
		bets.get_child(sn).set_chips(seat.actor.round_bet)

func _init_gui():
	gui.init_table_id(model.id)
	gui.init_slider_step(model.bb)

func _update_seat(m: Model.SeatChipsModel) -> void:
	var sn:int = _get_seat_scene_sn(m.seat_id)
	seats.get_child(sn).get_child(1).set_chips(m.actor_chips)
	bets.get_child(sn).set_chips(m.chips)

func _show_hands(hands: Array) -> void:
	for hand in hands:
		var sn:int = _get_seat_scene_sn(hand.id)
		seats.get_child(sn).show_cards(hand.cards)


func _update_seat_chips(chips: Array) -> void:
	for c in chips:
		var sn:int = _get_seat_scene_sn(c.seat_id)
		seats.get_child(sn).get_child(1).set_chips(c.actor_chips)
		bets.get_child(sn).set_chips(c.chips)
		
func _update_seat_state(seat_state: Model.SeatStateModel) -> void:
	var sn:int = _get_seat_scene_sn(seat_state.seat_id)
	seats.get_child(sn).get_child(1).set_state(seat_state.state)
	

func _actor_win(items: Array) -> void:
	for c in items:
		var sn:int = _get_seat_scene_sn(c.seat_id)
		seats.get_child(sn).get_child(1).set_chips(c.chips)
		bets.get_child(sn).set_chips(c.pot)

func _init_pot():
	pot.set_pot(model.total_pot, model.current_pot)

func _update_total_pot(value: int):
	model.total_pot = value
	pot.set_total_pot(model.total_pot)

func _update_current_pot(value: int):
	model.current_pot = value
	pot.set_current_pot(model.current_pot)


func _init_community_cards() -> void:
	community_cards.set_cards(model.community_cards)


func _init_active_seat() -> void:
	if model.active_seat.id != 0:
		var sn = _get_seat_scene_sn(model.active_seat.id)
		seats.get_child(sn).set_active(model.active_seat.remain_sec)


# ------------------------------------------------------------------------------
# get seat sccne child sn

func _get_seat_scene_sn(seat_id: int) -> int:
	if hero_seat == 0:
		return seat_id - 1
	var sn:int = seat_id - hero_seat
	if sn < 0:
		sn += model.total_seats
	return sn
	
# ------------------------------------------------------------------------------
func _hero_sit_down(seat: Model.SeatModel) -> void:
	hero_seat = seat.id
	model.seats.push_back(seat)
	_reload_table()

func _opponent_sit_down(seat: Model.SeatModel) -> void:
	model.seats.push_back(seat)
	var sn:int = _get_seat_scene_sn(seat.id)
	seats.get_child(sn).initialize(seat, model.speed)
	bets.get_child(sn).set_chips(seat.actor.round_bet)

# ==============================================================================
# API
# ==============================================================================

func _waiting_state():
	_clear_seats()
	pass

# ------------------------------------------------------------------------------
# _clear_table
# ------------------------------------------------------------------------------

func _reload_table():
	_clear_seats()
	_clear_seats_bets()
	_init_seats()
	_init_active_seat()

func _clear_table():
	_clear_seats()
	_clear_seats_bets()
	_clear_pot()
	_clear_community_cards()

func _clear_seats():
#	model.seats = []
	for seat in seats.get_children():
		if len(seat.get_children()) == 2:
			seat.get_child(1).queue_free()

func _clear_seats_bets():
	for seat in bets.get_children():
		seat.set_chips(0)

func _clear_pot():
	model.total_pot = 0
	model.current_pot = 0
	pot.clear_pot()

func _clear_community_cards():
	community_cards.clear_cards()
