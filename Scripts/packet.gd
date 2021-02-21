class Packet:
	const MyProto = preload("res://scripts/all_pb.gd")
	
	static func encode(cmd, data):
		var c1 = int(cmd/256)
		var c2 = (cmd%256)
		var pb = data.to_bytes()
		var buf = PoolByteArray([c1,c2])
		buf.append_array(pb)
		return buf

	static func decode(buf):
		var e1 = buf[0]
		var e2 = buf[1]
		var c1 = buf[2]
		var c2 = buf[3]
		var size = buf.size()
		var pb = PoolByteArray([])
		if size != 4:
			pb = buf.subarray(4, size-1)
		
		var code = e1*256+e2
		var cmd = c1*256+c2
		
		if code == 0:
			unpack(cmd, pb)
		else:
			Store.set_error_code(code)
	
	static func unpack(cmd, pb):
		var proto = MyProto["m_" + str(cmd) + "_toc"].new()
		if len(pb) != 0:
			proto.from_bytes(pb)
		GlobalSignals.proto_signal(cmd, proto)
#		Store.set_proto(cmd, proto)
