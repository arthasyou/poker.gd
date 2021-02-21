# web socket

extends Node

var Packet = preload("res://Scripts/packet.gd").Packet

const HOST = "127.0.0.1"
#const DEF_PORT = 31000
const DEF_PORT = 30003
const PROTO_NAME = "protobuf"
const _write_mode = WebSocketPeer.WRITE_MODE_BINARY
const RECONNECT_TIME = 5

var peer = WebSocketClient.new()
var timer
var flag: bool = false

func _ready():
	peer.connect("connection_closed", self, "_closed")
	peer.connect("connection_error", self, "_closed")
	peer.connect("connection_established", self, "_connected")
	peer.connect("data_received", self, "_on_data")
	_connect_server()



func _connected(_proto = ""):
	peer.get_peer(1).set_write_mode(_write_mode)
	flag = true
#	var id = get_parameter()
	print("network connected")
	
	
func _closed(was_clean = false):
	flag = false
	print("close network: ", was_clean)
	_wait(RECONNECT_TIME)
#	_connect_server()
#	get_tree().set_network_peer(null)
	
func send_data(cmd, data):
	if flag:
		var buf = Packet.encode(cmd, data)
		peer.get_peer(1).put_packet(buf)

func _on_data():
#	print("_on_data")
	var buf = peer.get_peer(1).get_packet()
	Packet.decode(buf)

func _process(_delta):
	peer.poll()

func _connect_server():
	peer.connect_to_url("ws://" + HOST + ":" + str(DEF_PORT))

# web game pass the paramete
func get_parameter():
	if OS.has_feature('JavaScript'):
		return JavaScript.eval(""" 
				window.location.hash;
			""")
	return null
	
#signal timer_end

func _wait( seconds ):
	self._create_timer(self, seconds, true, "_emit_timer_end_signal")
#	yield(self,"timer_end")

func _emit_timer_end_signal():
	_connect_server()
#	emit_signal("timer_end")

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	timer = Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()
