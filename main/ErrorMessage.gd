extends CanvasLayer

onready var message

func _ready() -> void:
	var _ignore = GlobalSignals.connect("display_error", self, "_handle_error")


func _handle_error(code: int) -> void:
	pass
	
