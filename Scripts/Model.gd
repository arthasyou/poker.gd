
# ==============================================================================
# Model2000
# ==============================================================================
class Model2000:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var info: TableModel	
	func _init(proto: MyProto.m_2000_toc) -> void:
		info = TableModel.new(proto.get_info())

# ==============================================================================
# Model2002
# ==============================================================================
class Model2002:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seat: SeatModel
	func _init(proto: MyProto.m_2002_toc) -> void:
		seat = SeatModel.new(proto.get_seat())

# ==============================================================================
# Model2010
# ==============================================================================
class Model2010:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seat_id:int
	func _init(proto: MyProto.m_2010_toc) -> void:
		seat_id = proto.get_seat_id()

# ==============================================================================
# Model2011
# ==============================================================================
#class Model2011:
#	const MyProto = preload("res://scripts/all_pb.gd")
#	var seat_id: int
#	func _init(proto: MyProto.m_2011_toc) -> void:
#		seat_id = proto.get_seat_id()

# ==============================================================================
# Model2012
# ==============================================================================
#class Model2012:
#	const MyProto = preload("res://scripts/all_pb.gd")	
#	var seat_id: int
#	func _init(proto: MyProto.m_2012_toc) -> void:
#		seat_id = proto.get_seat_id()

# ==============================================================================
# Model2013
# ==============================================================================
#class Model2013:
#	const MyProto = preload("res://scripts/all_pb.gd")
#	var info: SeatChipsModel
#	var total_pot: int
#	func _init(proto: MyProto.m_2013_toc) -> void:
#		info = SeatChipsModel.new(proto.get_info())
#		total_pot = proto.get_total_pot()

# ==============================================================================
# Model2014
# ==============================================================================
#class Model2014:
#	const MyProto = preload("res://scripts/all_pb.gd")
#	var info: SeatChipsModel
#	var total_pot: int
#	func _init(proto: MyProto.m_2014_toc) -> void:
#		info = SeatChipsModel.new(proto.get_info())
#		total_pot = proto.get_total_pot()

# ==============================================================================
# Model2021
# ==============================================================================
class Model2021:
	const MyProto = preload("res://scripts/all_pb.gd")
	var cards: Array
	func _init(proto: MyProto.m_2021_toc) -> void:
		cards = proto.get_cards()

# ==============================================================================
# Model2022
# ==============================================================================
class Model2022:
	const MyProto = preload("res://scripts/all_pb.gd")
	var card: String
	func _init(proto: MyProto.m_2022_toc) -> void:
		card = proto.get_card()

# ==============================================================================
# Model2023
# ==============================================================================
class Model2023:
	const MyProto = preload("res://scripts/all_pb.gd")
	var current_pot: int
	var sides: Array = []
	var seats_chips: Array = []
	func _init(proto: MyProto.m_2023_toc) -> void:
		current_pot = proto.get_current_pot()
		for i in proto.get_seats_chips():
			var seat_chips: SeatChipsModel = SeatChipsModel.new(i)
			seats_chips.push_back(seat_chips)
		for i in proto.get_side_pot():
			var seat: SidePotModel = SidePotModel.new(i)
			sides.push_back(seat)

# ==============================================================================
# Model2024
# ==============================================================================
class Model2024:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seats_chips: Array = []
	var total_pot: int
	var current_pot: int
	func _init(proto: MyProto.m_2024_toc) -> void:
		total_pot = proto.get_total_pot()
		current_pot = proto.get_current_pot()
		for i in proto.get_seats_chips():
			var seat_chips: SeatChipsModel = SeatChipsModel.new(i)
			seats_chips.push_back(seat_chips)

# ==============================================================================
# Model2025
# ==============================================================================
class Model2025:
	const MyProto = preload("res://scripts/all_pb.gd")
	var hands: Array = []	
	func _init(proto: MyProto.m_2025_toc) -> void:
		for i in proto.get_hands():
			var item: SeatHandModel = SeatHandModel.new(i)
			hands.push_back(item)

# ==============================================================================
# Model2026
# ==============================================================================
class Model2026:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seats: Array = []
	func _init(proto: MyProto.m_2026_toc) -> void:
		for i in proto.get_seats():
			var item: WinPotModel = WinPotModel.new(i)
			seats.push_back(item)

# ==============================================================================
# Model2027
# ==============================================================================
class Model2027:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seat: SeatModel
	func _init(proto: MyProto.m_2027_toc) -> void:
		seat = SeatModel.new(proto.get_seat())


# ==============================================================================
# Model2028
# ==============================================================================
class Model2028:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seat_state: SeatStateModel
	func _init(proto: MyProto.m_2028_toc) -> void:
		seat_state = SeatStateModel.new(proto.get_seat_state())

# ==============================================================================
# Model2029
# ==============================================================================
class Model2029:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seat_id: int
	var action_type: int
	var chips: int
	var pot: int
	var total_pot: int
	var current_pot: int
	func _init(proto: MyProto.m_2029_toc) -> void:
		seat_id = proto.get_seat_id()
		action_type = proto.get_action_type()
		chips = proto.get_chips()
		pot = proto.get_pot()
		total_pot = proto.get_total_pot()
		current_pot = proto.get_current_pot()

# ==============================================================================
# Model2030
# ==============================================================================
class Model2030:
	const MyProto = preload("res://scripts/all_pb.gd")
	var seats:Array
	var total_pot:int
	var current_pot:int
	func _init(proto: MyProto.m_2030_toc) -> void:
		for i in proto.get_seats():
			var seat: SeatModel = SeatModel.new(i)
			seats.push_back(seat)
		total_pot = proto.get_total_pot()
		current_pot = proto.get_current_pot()

# ==============================================================================
# TableModel
# ==============================================================================
class TableModel:
	const MyProto = preload("res://scripts/all_pb.gd")
	var id:int
	var table_type:int
	var total_seats:int
	var speed:int
	var sb:int
	var bb:int
	var ante:int
	var min_buy_in:int	#times BB
	var max_buy_in:int	#times BB
	var state:int
	var seats:Array = []
	var community_cards:Array
	var total_pot:int
	var current_pot:int
	var side_pot:Array = []
	var top_bet:int = 0
	var active_seat
	
	func _init(proto: MyProto.p_table) -> void:
		id = proto.get_id()
		table_type = proto.get_type_of_play()
		total_seats = proto.get_total_seats()
		speed = proto.get_speed()
		sb = proto.get_sb()
		bb = proto.get_bb()
		ante = proto.get_ante()
		min_buy_in = proto.get_min_buy_in()
		max_buy_in = proto.get_max_buy_in()
		state = proto.get_state()
		community_cards = proto.get_community_cards()
		total_pot = proto.get_total_pot()
		current_pot = proto.get_current_pot()
		for i in proto.get_side_pot():
			var sp: SidePotModel = SidePotModel.new(i)
			side_pot.push_back(sp)
		active_seat = ActiveSeatModel.new(proto.get_active_seat()) 
		for i in proto.get_seats():
			var seat: SeatModel = SeatModel.new(i)
			seats.push_back(seat)


# ==============================================================================
# ActorModel
# ==============================================================================
class ActorModel:
	const MyProto = preload("res://scripts/all_pb.gd")
	
	var name:String
	var chips: int
	var position: int
	var hands:Array = []
	var state:int
	var total_bet:int
	var round_bet:int
	
	func _init(proto: MyProto.p_actor) -> void:
		name = proto.get_name()
		chips = proto.get_chips()
		position = proto.get_position()
		hands = proto.get_hands()
		state = proto.get_state()
		total_bet = proto.get_total_bet()
		round_bet = proto.get_round_bet()
		
# ------------------------------------------------------------------------------
	func get_pos_text() -> String:
		match state:
			MyProto.e_actor_state.READY:
				return "Ready"
			MyProto.e_actor_state.FOLD:
				return "Fold"
			MyProto.e_actor_state.ACTIVE:
				match position:
					MyProto.e_table_position.BTN:
						return "BTN"
					MyProto.e_table_position.SB:
						return "SB"
					MyProto.e_table_position.BB:
						return "BB"
					MyProto.e_table_position.UTG:
						return "UTG"
					MyProto.e_table_position.HJ:
						return "HJ"
					MyProto.e_table_position.LJ:
						return "LJ"
					MyProto.e_table_position.CO:
						return "CO"
					MyProto.e_table_position.UTG1:
						return "UTG+1"
					MyProto.e_table_position.UTG2:
						return "UTG+2"
					MyProto.e_table_position.UTG3:
						return "UTG+3"
		return "Sit Out"
# ------------------------------------------------------------------------------
	func set_chips(value: int) -> void:
		self.chips = value
# ------------------------------------------------------------------------------
	func increase_chips(value: int) -> void:
		self.chips += value
# ------------------------------------------------------------------------------
	func reduce_chips(value: int) -> bool:
		if self.check_chips(value):
			self.chips -= value
			return true
		return false
# ------------------------------------------------------------------------------
	func check_chips(value: int) -> bool:
		if self.chips >= value:
			return true
		return false

# ==============================================================================
# SeatModel
# ==============================================================================
class SeatModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var id:int
	var actor_type:int
	var actor	
	func _init(proto: MyProto.p_seat) -> void:
		id = proto.get_id()
		actor_type = proto.get_type()
		actor = ActorModel.new(proto.get_actor())

# ==============================================================================
# ActiveSeatModel
# ==============================================================================
class ActiveSeatModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var id:int
	var remain_sec:int	
	func _init(proto: MyProto.p_active_seat) -> void:
		id = proto.get_id()
		remain_sec = proto.get_remain_sec()

# ==============================================================================
# SeatChipsModel
# ==============================================================================
class SeatChipsModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var seat_id:int
	var chips:int
	var actor_chips:int	
	func _init(proto: MyProto.p_seat_chips) -> void:
		seat_id = proto.get_seat_id()
		chips = proto.get_chips()
		actor_chips = proto.get_actor_chips()
		
# ==============================================================================
# SidePotModel
# ==============================================================================
class SidePotModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var id:int
	var pot:int
	func _init(proto: MyProto.p_side_pot) -> void:
		id = proto.get_id()
		pot = proto.get_pot()

# ==============================================================================
# SeatHandModel
# ==============================================================================
class SeatHandModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var id:int
	var cards: Array	
	func _init(proto: MyProto.p_seat_hand) -> void:
		id = proto.get_seat_id()
		cards = proto.get_cards()

# ==============================================================================
# SeatStateModel
# ==============================================================================
class SeatStateModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var seat_id:int
	var state: int
	func _init(proto: MyProto.p_seat_state) -> void:
		seat_id = proto.get_seat_id()
		state = proto.get_state()

# ==============================================================================
# WinPotModel
# ==============================================================================
class WinPotModel:
	const MyProto = preload("res://scripts/all_pb.gd")	
	var seat_id:int
	var pot:int
	var pot_ids: Array
	var chips:int
	func _init(proto: MyProto.p_win_pot) -> void:
		seat_id = proto.get_seat_id()
		pot = proto.get_pot()
		pot_ids = proto.get_pot_ids()
		chips = proto.get_chips()
		
