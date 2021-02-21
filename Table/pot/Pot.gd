extends Node2D

onready var total_pot = $TotalPot
onready var current_pot = $CurrentPot

func _ready() -> void:
	pass

func set_pot(total: int, current: int) -> void:
	set_total_pot(total)
	set_current_pot(current)

func set_total_pot(value: int) -> void:
	total_pot.set_pot(value)

func set_current_pot(value: int) -> void:
	current_pot.set_pot(value)
	
func clear_pot() -> void:
	total_pot.set_pot(0)
	current_pot.set_pot(0)
