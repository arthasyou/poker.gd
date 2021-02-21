extends Node

signal actor_blind(seat, value)
signal actor_bet(seat, value)
signal actor_call(seat)
signal actor_fold(seat)



func actor_blind(seat: int, value: float) -> void:
	emit_signal("actor_blind", seat, value)

func actor_bet(seat: int, value: float) -> void:
	emit_signal("actor_bet", seat, value)

func actor_call(seat: int) -> void:
	emit_signal("actor_call", seat)

func actor_fold(seat: int) -> void:
	emit_signal("actor_fold", seat)

# ==============================================================================
# error signal
# ==============================================================================
signal display_error(code)

# ==============================================================================
# proto signal
# ==============================================================================
signal m_1001_toc(data)

#-------------------------------------------------------------------------------
# hold'em
#-------------------------------------------------------------------------------
signal m_2000_toc(data)
signal m_2001_toc(data)
signal m_2002_toc(data)
signal m_2010_toc(data)
#signal m_2011_toc(data)
#signal m_2012_toc(data)
#signal m_2013_toc(data)
#signal m_2014_toc(data)
signal m_2020_toc(data)
signal m_2021_toc(data)
signal m_2022_toc(data)
signal m_2023_toc(data)
signal m_2024_toc(data)
signal m_2025_toc(data)
signal m_2026_toc(data)
signal m_2027_toc(data)
signal m_2028_toc(data)
signal m_2029_toc(data)
signal m_2030_toc(data)

func proto_signal(cmd:int, data) -> void:
	emit_signal("m_" + str(cmd) + "_toc", data)

func error_signal(code: int) -> void:
	emit_signal("display_error", code)
