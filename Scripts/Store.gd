extends Node

const MyProto = preload("res://scripts/all_pb.gd")

var rng = RandomNumberGenerator.new()

var _errorCode:int = 0
var _proto:Dictionary = {}

var _settings = {}



# ==============================================================================
# initialize
# ==============================================================================

func _ready() -> void:
	rng.randomize()
	_initialize()

func _initialize() -> void:
	_initialize_settings()
	
func _initialize_settings() -> void:
	_settings["bet1"] = "min"
	_settings["bet2"] = "1/2"
	_settings["bet3"] = "3/4"
	_settings["bet4"] = "1/1"
	_settings["bet5"] = "max"
	
	_settings["prebet1"] = "min"
	_settings["prebet2"] = "2"
	_settings["prebet3"] = "3"
	_settings["prebet4"] = "4"
	_settings["prebet5"] = "max"

# ==============================================================================
# API
# ==============================================================================

func get_settings(key):
	return _settings[key]

func set_proto(cmd, proto):
	_proto[cmd] = proto
	
	

func get_proto(cmd):
	return _proto[cmd]
	
func set_error_code(code):
	_errorCode = code 

func get_code():
	return _errorCode
