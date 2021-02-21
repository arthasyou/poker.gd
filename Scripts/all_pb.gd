const PROTO_VERSION = 3

#
# BSD 3-Clause License
#
# Copyright (c) 2018 - 2020, Oleg Malyavkin
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# DEBUG_TAB redefine this "  " if you need, example: const DEBUG_TAB = "\t"
const DEBUG_TAB : String = "  "

enum PB_ERR {
	NO_ERRORS = 0,
	VARINT_NOT_FOUND = -1,
	REPEATED_COUNT_NOT_FOUND = -2,
	REPEATED_COUNT_MISMATCH = -3,
	LENGTHDEL_SIZE_NOT_FOUND = -4,
	LENGTHDEL_SIZE_MISMATCH = -5,
	PACKAGE_SIZE_MISMATCH = -6,
	UNDEFINED_STATE = -7,
	PARSE_INCOMPLETE = -8,
	REQUIRED_FIELDS = -9
}

enum PB_DATA_TYPE {
	INT32 = 0,
	SINT32 = 1,
	UINT32 = 2,
	INT64 = 3,
	SINT64 = 4,
	UINT64 = 5,
	BOOL = 6,
	ENUM = 7,
	FIXED32 = 8,
	SFIXED32 = 9,
	FLOAT = 10,
	FIXED64 = 11,
	SFIXED64 = 12,
	DOUBLE = 13,
	STRING = 14,
	BYTES = 15,
	MESSAGE = 16,
	MAP = 17
}

const DEFAULT_VALUES_2 = {
	PB_DATA_TYPE.INT32: null,
	PB_DATA_TYPE.SINT32: null,
	PB_DATA_TYPE.UINT32: null,
	PB_DATA_TYPE.INT64: null,
	PB_DATA_TYPE.SINT64: null,
	PB_DATA_TYPE.UINT64: null,
	PB_DATA_TYPE.BOOL: null,
	PB_DATA_TYPE.ENUM: null,
	PB_DATA_TYPE.FIXED32: null,
	PB_DATA_TYPE.SFIXED32: null,
	PB_DATA_TYPE.FLOAT: null,
	PB_DATA_TYPE.FIXED64: null,
	PB_DATA_TYPE.SFIXED64: null,
	PB_DATA_TYPE.DOUBLE: null,
	PB_DATA_TYPE.STRING: null,
	PB_DATA_TYPE.BYTES: null,
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: null
}

const DEFAULT_VALUES_3 = {
	PB_DATA_TYPE.INT32: 0,
	PB_DATA_TYPE.SINT32: 0,
	PB_DATA_TYPE.UINT32: 0,
	PB_DATA_TYPE.INT64: 0,
	PB_DATA_TYPE.SINT64: 0,
	PB_DATA_TYPE.UINT64: 0,
	PB_DATA_TYPE.BOOL: false,
	PB_DATA_TYPE.ENUM: 0,
	PB_DATA_TYPE.FIXED32: 0,
	PB_DATA_TYPE.SFIXED32: 0,
	PB_DATA_TYPE.FLOAT: 0.0,
	PB_DATA_TYPE.FIXED64: 0,
	PB_DATA_TYPE.SFIXED64: 0,
	PB_DATA_TYPE.DOUBLE: 0.0,
	PB_DATA_TYPE.STRING: "",
	PB_DATA_TYPE.BYTES: [],
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: []
}

enum PB_TYPE {
	VARINT = 0,
	FIX64 = 1,
	LENGTHDEL = 2,
	STARTGROUP = 3,
	ENDGROUP = 4,
	FIX32 = 5,
	UNDEFINED = 8
}

enum PB_RULE {
	OPTIONAL = 0,
	REQUIRED = 1,
	REPEATED = 2,
	RESERVED = 3
}

enum PB_SERVICE_STATE {
	FILLED = 0,
	UNFILLED = 1
}

class PBField:
	func _init(a_name : String, a_type : int, a_rule : int, a_tag : int, packed : bool, a_value = null):
		name = a_name
		type = a_type
		rule = a_rule
		tag = a_tag
		option_packed = packed
		value = a_value
	var name : String
	var type : int
	var rule : int
	var tag : int
	var option_packed : bool
	var value
	var option_default : bool = false

class PBTypeTag:
	var ok : bool = false
	var type : int
	var tag : int
	var offset : int

class PBServiceField:
	var field : PBField
	var func_ref = null
	var state : int = PB_SERVICE_STATE.UNFILLED

class PBPacker:
	static func convert_signed(n : int) -> int:
		if n < -2147483648:
			return (n << 1) ^ (n >> 63)
		else:
			return (n << 1) ^ (n >> 31)

	static func deconvert_signed(n : int) -> int:
		if n & 0x01:
			return ~(n >> 1)
		else:
			return (n >> 1)

	static func pack_varint(value) -> PoolByteArray:
		var varint : PoolByteArray = PoolByteArray()
		if typeof(value) == TYPE_BOOL:
			if value:
				value = 1
			else:
				value = 0
		for i in range(9):
			var b = value & 0x7F
			value >>= 7
			if value:
				varint.append(b | 0x80)
			else:
				varint.append(b)
				break
		if varint.size() == 9 && varint[8] == 0xFF:
			varint.append(0x01)
		return varint

	static func pack_bytes(value, count : int, data_type : int) -> PoolByteArray:
		var bytes : PoolByteArray = PoolByteArray()
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb : StreamPeerBuffer = StreamPeerBuffer.new()
			spb.put_float(value)
			bytes = spb.get_data_array()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb : StreamPeerBuffer = StreamPeerBuffer.new()
			spb.put_double(value)
			bytes = spb.get_data_array()
		else:
			for i in range(count):
				bytes.append(value & 0xFF)
				value >>= 8
		return bytes

	static func unpack_bytes(bytes : PoolByteArray, index : int, count : int, data_type : int):
		var value = 0
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb : StreamPeerBuffer = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_float()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb : StreamPeerBuffer = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_double()
		else:
			for i in range(index + count - 1, index - 1, -1):
				value |= (bytes[i] & 0xFF)
				if i != index:
					value <<= 8
		return value

	static func unpack_varint(varint_bytes) -> int:
		var value : int = 0
		for i in range(varint_bytes.size() - 1, -1, -1):
			value |= varint_bytes[i] & 0x7F
			if i != 0:
				value <<= 7
		return value

	static func pack_type_tag(type : int, tag : int) -> PoolByteArray:
		return pack_varint((tag << 3) | type)

	static func isolate_varint(bytes : PoolByteArray, index : int) -> PoolByteArray:
		var result : PoolByteArray = PoolByteArray()
		for i in range(index, bytes.size()):
			result.append(bytes[i])
			if !(bytes[i] & 0x80):
				break
		return result

	static func unpack_type_tag(bytes : PoolByteArray, index : int) -> PBTypeTag:
		var varint_bytes : PoolByteArray = isolate_varint(bytes, index)
		var result : PBTypeTag = PBTypeTag.new()
		if varint_bytes.size() != 0:
			result.ok = true
			result.offset = varint_bytes.size()
			var unpacked : int = unpack_varint(varint_bytes)
			result.type = unpacked & 0x07
			result.tag = unpacked >> 3
		return result

	static func pack_length_delimeted(type : int, tag : int, bytes : PoolByteArray) -> PoolByteArray:
		var result : PoolByteArray = pack_type_tag(type, tag)
		result.append_array(pack_varint(bytes.size()))
		result.append_array(bytes)
		return result

	static func pb_type_from_data_type(data_type : int) -> int:
		if data_type == PB_DATA_TYPE.INT32 || data_type == PB_DATA_TYPE.SINT32 || data_type == PB_DATA_TYPE.UINT32 || data_type == PB_DATA_TYPE.INT64 || data_type == PB_DATA_TYPE.SINT64 || data_type == PB_DATA_TYPE.UINT64 || data_type == PB_DATA_TYPE.BOOL || data_type == PB_DATA_TYPE.ENUM:
			return PB_TYPE.VARINT
		elif data_type == PB_DATA_TYPE.FIXED32 || data_type == PB_DATA_TYPE.SFIXED32 || data_type == PB_DATA_TYPE.FLOAT:
			return PB_TYPE.FIX32
		elif data_type == PB_DATA_TYPE.FIXED64 || data_type == PB_DATA_TYPE.SFIXED64 || data_type == PB_DATA_TYPE.DOUBLE:
			return PB_TYPE.FIX64
		elif data_type == PB_DATA_TYPE.STRING || data_type == PB_DATA_TYPE.BYTES || data_type == PB_DATA_TYPE.MESSAGE || data_type == PB_DATA_TYPE.MAP:
			return PB_TYPE.LENGTHDEL
		else:
			return PB_TYPE.UNDEFINED

	static func pack_field(field : PBField) -> PoolByteArray:
		var type : int = pb_type_from_data_type(field.type)
		var type_copy : int = type
		if field.rule == PB_RULE.REPEATED && field.option_packed:
			type = PB_TYPE.LENGTHDEL
		var head : PoolByteArray = pack_type_tag(type, field.tag)
		var data : PoolByteArray = PoolByteArray()
		if type == PB_TYPE.VARINT:
			var value
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						value = convert_signed(v)
					else:
						value = v
					data.append_array(pack_varint(value))
				return data
			else:
				if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
					value = convert_signed(field.value)
				else:
					value = field.value
				data = pack_varint(value)
		elif type == PB_TYPE.FIX32:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 4, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 4, field.type))
		elif type == PB_TYPE.FIX64:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 8, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 8, field.type))
		elif type == PB_TYPE.LENGTHDEL:
			if field.rule == PB_RULE.REPEATED:
				if type_copy == PB_TYPE.VARINT:
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						var signed_value : int
						for v in field.value:
							signed_value = convert_signed(v)
							data.append_array(pack_varint(signed_value))
					else:
						for v in field.value:
							data.append_array(pack_varint(v))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX32:
					for v in field.value:
						data.append_array(pack_bytes(v, 4, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX64:
					for v in field.value:
						data.append_array(pack_bytes(v, 8, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif field.type == PB_DATA_TYPE.STRING:
					for v in field.value:
						var obj = v.to_utf8()
						data.append_array(pack_length_delimeted(type, field.tag, obj))
					return data
				elif field.type == PB_DATA_TYPE.BYTES:
					for v in field.value:
						data.append_array(pack_length_delimeted(type, field.tag, v))
					return data
				elif typeof(field.value[0]) == TYPE_OBJECT:
					for v in field.value:
						var obj : PoolByteArray = v.to_bytes()
						#if obj != null && obj.size() > 0:
						#	data.append_array(pack_length_delimeted(type, field.tag, obj))
						#else:
						#	data = PoolByteArray()
						#	return data
						data.append_array(pack_length_delimeted(type, field.tag, obj))
					return data
			else:
				if field.type == PB_DATA_TYPE.STRING:
					var str_bytes : PoolByteArray = field.value.to_utf8()
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && str_bytes.size() > 0):
						data.append_array(str_bytes)
						return pack_length_delimeted(type, field.tag, data)
				if field.type == PB_DATA_TYPE.BYTES:
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && field.value.size() > 0):
						data.append_array(field.value)
						return pack_length_delimeted(type, field.tag, data)
				elif typeof(field.value) == TYPE_OBJECT:
					var obj : PoolByteArray = field.value.to_bytes()
					#if obj != null && obj.size() > 0:
					#	data.append_array(obj)
					#	return pack_length_delimeted(type, field.tag, data)
					if obj.size() > 0:
						data.append_array(obj)
					return pack_length_delimeted(type, field.tag, data)
				else:
					pass
		if data.size() > 0:
			head.append_array(data)
			return head
		else:
			return data

	static func unpack_field(bytes : PoolByteArray, offset : int, field : PBField, type : int, message_func_ref) -> int:
		if field.rule == PB_RULE.REPEATED && type != PB_TYPE.LENGTHDEL && field.option_packed:
			var count = isolate_varint(bytes, offset)
			if count.size() > 0:
				offset += count.size()
				count = unpack_varint(count)
				if type == PB_TYPE.VARINT:
					var val
					var counter = offset + count
					while offset < counter:
						val = isolate_varint(bytes, offset)
						if val.size() > 0:
							offset += val.size()
							val = unpack_varint(val)
							if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
								val = deconvert_signed(val)
							elif field.type == PB_DATA_TYPE.BOOL:
								if val:
									val = true
								else:
									val = false
							field.value.append(val)
						else:
							return PB_ERR.REPEATED_COUNT_MISMATCH
					return offset
				elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
					var type_size
					if type == PB_TYPE.FIX32:
						type_size = 4
					else:
						type_size = 8
					var val
					var counter = offset + count
					while offset < counter:
						if (offset + type_size) > bytes.size():
							return PB_ERR.REPEATED_COUNT_MISMATCH
						val = unpack_bytes(bytes, offset, type_size, field.type)
						offset += type_size
						field.value.append(val)
					return offset
			else:
				return PB_ERR.REPEATED_COUNT_NOT_FOUND
		else:
			if type == PB_TYPE.VARINT:
				var val = isolate_varint(bytes, offset)
				if val.size() > 0:
					offset += val.size()
					val = unpack_varint(val)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						val = deconvert_signed(val)
					elif field.type == PB_DATA_TYPE.BOOL:
						if val:
							val = true
						else:
							val = false
					if field.rule == PB_RULE.REPEATED:
						field.value.append(val)
					else:
						field.value = val
				else:
					return PB_ERR.VARINT_NOT_FOUND
				return offset
			elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
				var type_size
				if type == PB_TYPE.FIX32:
					type_size = 4
				else:
					type_size = 8
				var val
				if (offset + type_size) > bytes.size():
					return PB_ERR.REPEATED_COUNT_MISMATCH
				val = unpack_bytes(bytes, offset, type_size, field.type)
				offset += type_size
				if field.rule == PB_RULE.REPEATED:
					field.value.append(val)
				else:
					field.value = val
				return offset
			elif type == PB_TYPE.LENGTHDEL:
				var inner_size = isolate_varint(bytes, offset)
				if inner_size.size() > 0:
					offset += inner_size.size()
					inner_size = unpack_varint(inner_size)
					if inner_size >= 0:
						if inner_size + offset > bytes.size():
							return PB_ERR.LENGTHDEL_SIZE_MISMATCH
						if message_func_ref != null:
							var message = message_func_ref.call_func()
							if inner_size > 0:
								var sub_offset = message.from_bytes(bytes, offset, inner_size + offset)
								if sub_offset > 0:
									if sub_offset - offset >= inner_size:
										offset = sub_offset
										return offset
									else:
										return PB_ERR.LENGTHDEL_SIZE_MISMATCH
								return sub_offset
							else:
								return offset
						elif field.type == PB_DATA_TYPE.STRING:
							var str_bytes : PoolByteArray = PoolByteArray()
							for i in range(offset, inner_size + offset):
								str_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(str_bytes.get_string_from_utf8())
							else:
								field.value = str_bytes.get_string_from_utf8()
							return offset + inner_size
						elif field.type == PB_DATA_TYPE.BYTES:
							var val_bytes : PoolByteArray = PoolByteArray()
							for i in range(offset, inner_size + offset):
								val_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(val_bytes)
							else:
								field.value = val_bytes
							return offset + inner_size
					else:
						return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
				else:
					return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
		return PB_ERR.UNDEFINED_STATE

	static func unpack_message(data, bytes : PoolByteArray, offset : int, limit : int) -> int:
		while true:
			var tt : PBTypeTag = unpack_type_tag(bytes, offset)
			if tt.ok:
				offset += tt.offset
				if data.has(tt.tag):
					var service : PBServiceField = data[tt.tag]
					var type : int = pb_type_from_data_type(service.field.type)
					if type == tt.type || (tt.type == PB_TYPE.LENGTHDEL && service.field.rule == PB_RULE.REPEATED && service.field.option_packed):
						var res : int = unpack_field(bytes, offset, service.field, type, service.func_ref)
						if res > 0:
							service.state = PB_SERVICE_STATE.FILLED
							offset = res
							if offset == limit:
								return offset
							elif offset > limit:
								return PB_ERR.PACKAGE_SIZE_MISMATCH
						elif res < 0:
							return res
						else:
							break
			else:
				return offset
		return PB_ERR.UNDEFINED_STATE

	static func pack_message(data) -> PoolByteArray:
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result : PoolByteArray = PoolByteArray()
		var keys : Array = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result.append_array(pack_field(data[i].field))
			elif data[i].field.rule == PB_RULE.REQUIRED:
				print("Error: required field is not filled: Tag:", data[i].field.tag)
				return PoolByteArray()
		return result

	static func check_required(data) -> bool:
		var keys : Array = data.keys()
		for i in keys:
			if data[i].field.rule == PB_RULE.REQUIRED && data[i].state == PB_SERVICE_STATE.UNFILLED:
				return false
		return true

	static func construct_map(key_values):
		var result = {}
		for kv in key_values:
			result[kv.get_key()] = kv.get_value()
		return result
	
	static func tabulate(text : String, nesting : int) -> String:
		var tab : String = ""
		for i in range(nesting):
			tab += DEBUG_TAB
		return tab + text
	
	static func value_to_string(value, field : PBField, nesting : int) -> String:
		var result : String = ""
		var text : String
		if field.type == PB_DATA_TYPE.MESSAGE:
			result += "{"
			nesting += 1
			text = message_to_string(value.data, nesting)
			if text != "":
				result += "\n" + text
				nesting -= 1
				result += tabulate("}", nesting)
			else:
				nesting -= 1
				result += "}"
		elif field.type == PB_DATA_TYPE.BYTES:
			result += "<"
			for i in range(value.size()):
				result += String(value[i])
				if i != (value.size() - 1):
					result += ", "
			result += ">"
		elif field.type == PB_DATA_TYPE.STRING:
			result += "\"" + value + "\""
		elif field.type == PB_DATA_TYPE.ENUM:
			result += "ENUM::" + String(value)
		else:
			result += String(value)
		return result
	
	static func field_to_string(field : PBField, nesting : int) -> String:
		var result : String = tabulate(field.name + ": ", nesting)
		if field.type == PB_DATA_TYPE.MAP:
			if field.value.size() > 0:
				result += "(\n"
				nesting += 1
				for i in range(field.value.size()):
					var local_key_value = field.value[i].data[1].field
					result += tabulate(value_to_string(local_key_value.value, local_key_value, nesting), nesting) + ": "
					local_key_value = field.value[i].data[2].field
					result += value_to_string(local_key_value.value, local_key_value, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate(")", nesting)
			else:
				result += "()"
		elif field.rule == PB_RULE.REPEATED:
			if field.value.size() > 0:
				result += "[\n"
				nesting += 1
				for i in range(field.value.size()):
					result += tabulate(String(i) + ": ", nesting)
					result += value_to_string(field.value[i], field, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate("]", nesting)
			else:
				result += "[]"
		else:
			result += value_to_string(field.value, field, nesting)
		result += ";\n"
		return result
		
	static func message_to_string(data, nesting : int = 0) -> String:
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result : String = ""
		var keys : Array = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result += field_to_string(data[i].field, nesting)
			elif data[i].field.rule == PB_RULE.REQUIRED:
				result += data[i].field.name + ": " + "error"
		return result



############### USER DATA BEGIN ################


class m_1001_tos:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_1001_toc:
	func _init():
		var service
		
		_flag = PBField.new("flag", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _flag
		data[_flag.tag] = service
		
	var data = {}
	
	var _flag: PBField
	func get_flag() -> int:
		return _flag.value
	func clear_flag() -> void:
		_flag.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_flag(value : int) -> void:
		_flag.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2000_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2000_toc:
	func _init():
		var service
		
		_info = PBField.new("info", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _info
		service.func_ref = funcref(self, "new_info")
		data[_info.tag] = service
		
	var data = {}
	
	var _info: PBField
	func get_info() -> p_table:
		return _info.value
	func clear_info() -> void:
		_info.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_info() -> p_table:
		_info.value = p_table.new()
		return _info.value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2001_tos:
	func _init():
		var service
		
	var data = {}
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2001_toc:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2002_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2002_toc:
	func _init():
		var service
		
		_seat = PBField.new("seat", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _seat
		service.func_ref = funcref(self, "new_seat")
		data[_seat.tag] = service
		
	var data = {}
	
	var _seat: PBField
	func get_seat() -> p_seat:
		return _seat.value
	func clear_seat() -> void:
		_seat.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_seat() -> p_seat:
		_seat.value = p_seat.new()
		return _seat.value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2003_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2003_toc:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2004_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2004_toc:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_seat_chips:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
		_chips = PBField.new("chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chips
		data[_chips.tag] = service
		
		_actor_chips = PBField.new("actor_chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _actor_chips
		data[_actor_chips.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	var _chips: PBField
	func get_chips() -> int:
		return _chips.value
	func clear_chips() -> void:
		_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_chips(value : int) -> void:
		_chips.value = value
	
	var _actor_chips: PBField
	func get_actor_chips() -> int:
		return _actor_chips.value
	func clear_actor_chips() -> void:
		_actor_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_actor_chips(value : int) -> void:
		_actor_chips.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2010_toc:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2011_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2012_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2013_tos:
	func _init():
		var service
		
		_table_id = PBField.new("table_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _table_id
		data[_table_id.tag] = service
		
		_chips = PBField.new("chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chips
		data[_chips.tag] = service
		
	var data = {}
	
	var _table_id: PBField
	func get_table_id() -> int:
		return _table_id.value
	func clear_table_id() -> void:
		_table_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_table_id(value : int) -> void:
		_table_id.value = value
	
	var _chips: PBField
	func get_chips() -> int:
		return _chips.value
	func clear_chips() -> void:
		_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_chips(value : int) -> void:
		_chips.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2021_toc:
	func _init():
		var service
		
		_cards = PBField.new("cards", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 1, true, [])
		service = PBServiceField.new()
		service.field = _cards
		data[_cards.tag] = service
		
	var data = {}
	
	var _cards: PBField
	func get_cards() -> Array:
		return _cards.value
	func clear_cards() -> void:
		_cards.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func add_cards(value : String) -> void:
		_cards.value.append(value)
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2022_toc:
	func _init():
		var service
		
		_card = PBField.new("card", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _card
		data[_card.tag] = service
		
	var data = {}
	
	var _card: PBField
	func get_card() -> String:
		return _card.value
	func clear_card() -> void:
		_card.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_card(value : String) -> void:
		_card.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2023_toc:
	func _init():
		var service
		
		_current_pot = PBField.new("current_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _current_pot
		data[_current_pot.tag] = service
		
		_side_pot = PBField.new("side_pot", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 2, true, [])
		service = PBServiceField.new()
		service.field = _side_pot
		service.func_ref = funcref(self, "add_side_pot")
		data[_side_pot.tag] = service
		
		_seats_chips = PBField.new("seats_chips", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 3, true, [])
		service = PBServiceField.new()
		service.field = _seats_chips
		service.func_ref = funcref(self, "add_seats_chips")
		data[_seats_chips.tag] = service
		
	var data = {}
	
	var _current_pot: PBField
	func get_current_pot() -> int:
		return _current_pot.value
	func clear_current_pot() -> void:
		_current_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_current_pot(value : int) -> void:
		_current_pot.value = value
	
	var _side_pot: PBField
	func get_side_pot() -> Array:
		return _side_pot.value
	func clear_side_pot() -> void:
		_side_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_side_pot() -> p_side_pot:
		var element = p_side_pot.new()
		_side_pot.value.append(element)
		return element
	
	var _seats_chips: PBField
	func get_seats_chips() -> Array:
		return _seats_chips.value
	func clear_seats_chips() -> void:
		_seats_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_seats_chips() -> p_seat_chips:
		var element = p_seat_chips.new()
		_seats_chips.value.append(element)
		return element
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2024_toc:
	func _init():
		var service
		
		_seats_chips = PBField.new("seats_chips", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, true, [])
		service = PBServiceField.new()
		service.field = _seats_chips
		service.func_ref = funcref(self, "add_seats_chips")
		data[_seats_chips.tag] = service
		
		_total_pot = PBField.new("total_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_pot
		data[_total_pot.tag] = service
		
		_current_pot = PBField.new("current_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _current_pot
		data[_current_pot.tag] = service
		
	var data = {}
	
	var _seats_chips: PBField
	func get_seats_chips() -> Array:
		return _seats_chips.value
	func clear_seats_chips() -> void:
		_seats_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_seats_chips() -> p_seat_chips:
		var element = p_seat_chips.new()
		_seats_chips.value.append(element)
		return element
	
	var _total_pot: PBField
	func get_total_pot() -> int:
		return _total_pot.value
	func clear_total_pot() -> void:
		_total_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_pot(value : int) -> void:
		_total_pot.value = value
	
	var _current_pot: PBField
	func get_current_pot() -> int:
		return _current_pot.value
	func clear_current_pot() -> void:
		_current_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_current_pot(value : int) -> void:
		_current_pot.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2025_toc:
	func _init():
		var service
		
		_hands = PBField.new("hands", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, true, [])
		service = PBServiceField.new()
		service.field = _hands
		service.func_ref = funcref(self, "add_hands")
		data[_hands.tag] = service
		
	var data = {}
	
	var _hands: PBField
	func get_hands() -> Array:
		return _hands.value
	func clear_hands() -> void:
		_hands.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_hands() -> p_seat_hand:
		var element = p_seat_hand.new()
		_hands.value.append(element)
		return element
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2026_toc:
	func _init():
		var service
		
		_seats = PBField.new("seats", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, true, [])
		service = PBServiceField.new()
		service.field = _seats
		service.func_ref = funcref(self, "add_seats")
		data[_seats.tag] = service
		
	var data = {}
	
	var _seats: PBField
	func get_seats() -> Array:
		return _seats.value
	func clear_seats() -> void:
		_seats.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_seats() -> p_win_pot:
		var element = p_win_pot.new()
		_seats.value.append(element)
		return element
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2027_toc:
	func _init():
		var service
		
		_seat = PBField.new("seat", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _seat
		service.func_ref = funcref(self, "new_seat")
		data[_seat.tag] = service
		
	var data = {}
	
	var _seat: PBField
	func get_seat() -> p_seat:
		return _seat.value
	func clear_seat() -> void:
		_seat.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_seat() -> p_seat:
		_seat.value = p_seat.new()
		return _seat.value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2028_toc:
	func _init():
		var service
		
		_seat_state = PBField.new("seat_state", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _seat_state
		service.func_ref = funcref(self, "new_seat_state")
		data[_seat_state.tag] = service
		
	var data = {}
	
	var _seat_state: PBField
	func get_seat_state() -> p_seat_state:
		return _seat_state.value
	func clear_seat_state() -> void:
		_seat_state.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_seat_state() -> p_seat_state:
		_seat_state.value = p_seat_state.new()
		return _seat_state.value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2029_toc:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
		_action_type = PBField.new("action_type", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _action_type
		data[_action_type.tag] = service
		
		_chips = PBField.new("chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chips
		data[_chips.tag] = service
		
		_pot = PBField.new("pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 4, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _pot
		data[_pot.tag] = service
		
		_total_pot = PBField.new("total_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 5, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_pot
		data[_total_pot.tag] = service
		
		_current_pot = PBField.new("current_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 6, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _current_pot
		data[_current_pot.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	var _action_type: PBField
	func get_action_type():
		return _action_type.value
	func clear_action_type() -> void:
		_action_type.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_action_type(value) -> void:
		_action_type.value = value
	
	var _chips: PBField
	func get_chips() -> int:
		return _chips.value
	func clear_chips() -> void:
		_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_chips(value : int) -> void:
		_chips.value = value
	
	var _pot: PBField
	func get_pot() -> int:
		return _pot.value
	func clear_pot() -> void:
		_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_pot(value : int) -> void:
		_pot.value = value
	
	var _total_pot: PBField
	func get_total_pot() -> int:
		return _total_pot.value
	func clear_total_pot() -> void:
		_total_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_pot(value : int) -> void:
		_total_pot.value = value
	
	var _current_pot: PBField
	func get_current_pot() -> int:
		return _current_pot.value
	func clear_current_pot() -> void:
		_current_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_current_pot(value : int) -> void:
		_current_pot.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class m_2030_toc:
	func _init():
		var service
		
		_seats = PBField.new("seats", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, true, [])
		service = PBServiceField.new()
		service.field = _seats
		service.func_ref = funcref(self, "add_seats")
		data[_seats.tag] = service
		
		_total_pot = PBField.new("total_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_pot
		data[_total_pot.tag] = service
		
		_current_pot = PBField.new("current_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _current_pot
		data[_current_pot.tag] = service
		
		_side_pot = PBField.new("side_pot", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 4, true, [])
		service = PBServiceField.new()
		service.field = _side_pot
		service.func_ref = funcref(self, "add_side_pot")
		data[_side_pot.tag] = service
		
	var data = {}
	
	var _seats: PBField
	func get_seats() -> Array:
		return _seats.value
	func clear_seats() -> void:
		_seats.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_seats() -> p_seat:
		var element = p_seat.new()
		_seats.value.append(element)
		return element
	
	var _total_pot: PBField
	func get_total_pot() -> int:
		return _total_pot.value
	func clear_total_pot() -> void:
		_total_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_pot(value : int) -> void:
		_total_pot.value = value
	
	var _current_pot: PBField
	func get_current_pot() -> int:
		return _current_pot.value
	func clear_current_pot() -> void:
		_current_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_current_pot(value : int) -> void:
		_current_pot.value = value
	
	var _side_pot: PBField
	func get_side_pot() -> Array:
		return _side_pot.value
	func clear_side_pot() -> void:
		_side_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_side_pot() -> p_side_pot:
		var element = p_side_pot.new()
		_side_pot.value.append(element)
		return element
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
enum e_table_position {
	NONE = 0,
	BTN = 1,
	SB = 2,
	BB = 3,
	UTG = 4,
	CO = 5,
	HJ = 6,
	LJ = 7,
	UTG1 = 8,
	UTG2 = 9,
	UTG3 = 10
}

enum e_table_state {
	waiting = 0,
	ready = 1,
	blind = 2,
	preflop = 3,
	flop = 4,
	turn = 5,
	river = 6,
	showdown = 7
}

enum e_table_speed {
	NONE = 0,
	SLOW = 30,
	NORMAL = 20,
	FAST = 10,
	RAPIDLY = 5,
	GOD = 1
}

enum e_actor_state {
	SIT_OUT = 0,
	READY = 1,
	FOLD = 2,
	ACTIVE = 3
}

enum e_game_type {
	NONE = 0,
	HOLDEM = 1,
	OMAHA = 2
}

enum e_type_of_play {
	NONE = 0,
	CASH = 1,
	TOURNAMENT = 2
}

enum e_actor_type {
	NONE = 0,
	HERO = 1,
	OPPONENT = 2
}

enum e_action_type {
	FOLD = 0,
	CHECK = 1,
	CALL = 2,
	BET = 3,
	RAISE = 4
}

class p_table:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_game_type = PBField.new("game_type", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _game_type
		data[_game_type.tag] = service
		
		_type_of_play = PBField.new("type_of_play", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _type_of_play
		data[_type_of_play.tag] = service
		
		_total_seats = PBField.new("total_seats", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 4, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_seats
		data[_total_seats.tag] = service
		
		_speed = PBField.new("speed", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 5, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _speed
		data[_speed.tag] = service
		
		_sb = PBField.new("sb", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 6, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _sb
		data[_sb.tag] = service
		
		_bb = PBField.new("bb", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 7, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _bb
		data[_bb.tag] = service
		
		_ante = PBField.new("ante", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 8, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _ante
		data[_ante.tag] = service
		
		_min_buy_in = PBField.new("min_buy_in", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 9, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _min_buy_in
		data[_min_buy_in.tag] = service
		
		_max_buy_in = PBField.new("max_buy_in", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 10, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _max_buy_in
		data[_max_buy_in.tag] = service
		
		_seats = PBField.new("seats", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 11, true, [])
		service = PBServiceField.new()
		service.field = _seats
		service.func_ref = funcref(self, "add_seats")
		data[_seats.tag] = service
		
		_community_cards = PBField.new("community_cards", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 12, true, [])
		service = PBServiceField.new()
		service.field = _community_cards
		data[_community_cards.tag] = service
		
		_total_pot = PBField.new("total_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 13, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_pot
		data[_total_pot.tag] = service
		
		_current_pot = PBField.new("current_pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 14, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _current_pot
		data[_current_pot.tag] = service
		
		_side_pot = PBField.new("side_pot", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 15, true, [])
		service = PBServiceField.new()
		service.field = _side_pot
		service.func_ref = funcref(self, "add_side_pot")
		data[_side_pot.tag] = service
		
		_active_seat = PBField.new("active_seat", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 16, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _active_seat
		service.func_ref = funcref(self, "new_active_seat")
		data[_active_seat.tag] = service
		
		_state = PBField.new("state", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 17, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _state
		data[_state.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	var _game_type: PBField
	func get_game_type():
		return _game_type.value
	func clear_game_type() -> void:
		_game_type.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_game_type(value) -> void:
		_game_type.value = value
	
	var _type_of_play: PBField
	func get_type_of_play():
		return _type_of_play.value
	func clear_type_of_play() -> void:
		_type_of_play.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_type_of_play(value) -> void:
		_type_of_play.value = value
	
	var _total_seats: PBField
	func get_total_seats() -> int:
		return _total_seats.value
	func clear_total_seats() -> void:
		_total_seats.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_seats(value : int) -> void:
		_total_seats.value = value
	
	var _speed: PBField
	func get_speed():
		return _speed.value
	func clear_speed() -> void:
		_speed.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_speed(value) -> void:
		_speed.value = value
	
	var _sb: PBField
	func get_sb() -> int:
		return _sb.value
	func clear_sb() -> void:
		_sb.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_sb(value : int) -> void:
		_sb.value = value
	
	var _bb: PBField
	func get_bb() -> int:
		return _bb.value
	func clear_bb() -> void:
		_bb.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_bb(value : int) -> void:
		_bb.value = value
	
	var _ante: PBField
	func get_ante() -> int:
		return _ante.value
	func clear_ante() -> void:
		_ante.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_ante(value : int) -> void:
		_ante.value = value
	
	var _min_buy_in: PBField
	func get_min_buy_in() -> int:
		return _min_buy_in.value
	func clear_min_buy_in() -> void:
		_min_buy_in.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_min_buy_in(value : int) -> void:
		_min_buy_in.value = value
	
	var _max_buy_in: PBField
	func get_max_buy_in() -> int:
		return _max_buy_in.value
	func clear_max_buy_in() -> void:
		_max_buy_in.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_max_buy_in(value : int) -> void:
		_max_buy_in.value = value
	
	var _seats: PBField
	func get_seats() -> Array:
		return _seats.value
	func clear_seats() -> void:
		_seats.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_seats() -> p_seat:
		var element = p_seat.new()
		_seats.value.append(element)
		return element
	
	var _community_cards: PBField
	func get_community_cards() -> Array:
		return _community_cards.value
	func clear_community_cards() -> void:
		_community_cards.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func add_community_cards(value : String) -> void:
		_community_cards.value.append(value)
	
	var _total_pot: PBField
	func get_total_pot() -> int:
		return _total_pot.value
	func clear_total_pot() -> void:
		_total_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_pot(value : int) -> void:
		_total_pot.value = value
	
	var _current_pot: PBField
	func get_current_pot() -> int:
		return _current_pot.value
	func clear_current_pot() -> void:
		_current_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_current_pot(value : int) -> void:
		_current_pot.value = value
	
	var _side_pot: PBField
	func get_side_pot() -> Array:
		return _side_pot.value
	func clear_side_pot() -> void:
		_side_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func add_side_pot() -> p_side_pot:
		var element = p_side_pot.new()
		_side_pot.value.append(element)
		return element
	
	var _active_seat: PBField
	func get_active_seat() -> p_active_seat:
		return _active_seat.value
	func clear_active_seat() -> void:
		_active_seat.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_active_seat() -> p_active_seat:
		_active_seat.value = p_active_seat.new()
		return _active_seat.value
	
	var _state: PBField
	func get_state():
		return _state.value
	func clear_state() -> void:
		_state.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_state(value) -> void:
		_state.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_seat:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_type = PBField.new("type", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _type
		data[_type.tag] = service
		
		_actor = PBField.new("actor", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _actor
		service.func_ref = funcref(self, "new_actor")
		data[_actor.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	var _type: PBField
	func get_type():
		return _type.value
	func clear_type() -> void:
		_type.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_type(value) -> void:
		_type.value = value
	
	var _actor: PBField
	func get_actor() -> p_actor:
		return _actor.value
	func clear_actor() -> void:
		_actor.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_actor() -> p_actor:
		_actor.value = p_actor.new()
		return _actor.value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_actor:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_state = PBField.new("state", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _state
		data[_state.tag] = service
		
		_position = PBField.new("position", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 4, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _position
		data[_position.tag] = service
		
		_chips = PBField.new("chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 5, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chips
		data[_chips.tag] = service
		
		_total_bet = PBField.new("total_bet", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 6, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _total_bet
		data[_total_bet.tag] = service
		
		_round_bet = PBField.new("round_bet", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 7, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _round_bet
		data[_round_bet.tag] = service
		
		_hands = PBField.new("hands", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 8, true, [])
		service = PBServiceField.new()
		service.field = _hands
		data[_hands.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	var _name: PBField
	func get_name() -> String:
		return _name.value
	func clear_name() -> void:
		_name.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_name(value : String) -> void:
		_name.value = value
	
	var _state: PBField
	func get_state():
		return _state.value
	func clear_state() -> void:
		_state.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_state(value) -> void:
		_state.value = value
	
	var _position: PBField
	func get_position():
		return _position.value
	func clear_position() -> void:
		_position.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_position(value) -> void:
		_position.value = value
	
	var _chips: PBField
	func get_chips() -> int:
		return _chips.value
	func clear_chips() -> void:
		_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_chips(value : int) -> void:
		_chips.value = value
	
	var _total_bet: PBField
	func get_total_bet() -> int:
		return _total_bet.value
	func clear_total_bet() -> void:
		_total_bet.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_total_bet(value : int) -> void:
		_total_bet.value = value
	
	var _round_bet: PBField
	func get_round_bet() -> int:
		return _round_bet.value
	func clear_round_bet() -> void:
		_round_bet.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_round_bet(value : int) -> void:
		_round_bet.value = value
	
	var _hands: PBField
	func get_hands() -> Array:
		return _hands.value
	func clear_hands() -> void:
		_hands.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func add_hands(value : String) -> void:
		_hands.value.append(value)
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_active_seat:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_remain_sec = PBField.new("remain_sec", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _remain_sec
		data[_remain_sec.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	var _remain_sec: PBField
	func get_remain_sec() -> int:
		return _remain_sec.value
	func clear_remain_sec() -> void:
		_remain_sec.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_remain_sec(value : int) -> void:
		_remain_sec.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_side_pot:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_pot = PBField.new("pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _pot
		data[_pot.tag] = service
		
	var data = {}
	
	var _id: PBField
	func get_id() -> int:
		return _id.value
	func clear_id() -> void:
		_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_id(value : int) -> void:
		_id.value = value
	
	var _pot: PBField
	func get_pot() -> int:
		return _pot.value
	func clear_pot() -> void:
		_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_pot(value : int) -> void:
		_pot.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_seat_hand:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
		_cards = PBField.new("cards", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 2, true, [])
		service = PBServiceField.new()
		service.field = _cards
		data[_cards.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	var _cards: PBField
	func get_cards() -> Array:
		return _cards.value
	func clear_cards() -> void:
		_cards.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func add_cards(value : String) -> void:
		_cards.value.append(value)
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_seat_state:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
		_state = PBField.new("state", PB_DATA_TYPE.ENUM, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM])
		service = PBServiceField.new()
		service.field = _state
		data[_state.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	var _state: PBField
	func get_state():
		return _state.value
	func clear_state() -> void:
		_state.value = DEFAULT_VALUES_3[PB_DATA_TYPE.ENUM]
	func set_state(value) -> void:
		_state.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class p_win_pot:
	func _init():
		var service
		
		_seat_id = PBField.new("seat_id", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _seat_id
		data[_seat_id.tag] = service
		
		_pot = PBField.new("pot", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _pot
		data[_pot.tag] = service
		
		_pot_ids = PBField.new("pot_ids", PB_DATA_TYPE.UINT32, PB_RULE.REPEATED, 3, true, [])
		service = PBServiceField.new()
		service.field = _pot_ids
		data[_pot_ids.tag] = service
		
		_chips = PBField.new("chips", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 4, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chips
		data[_chips.tag] = service
		
	var data = {}
	
	var _seat_id: PBField
	func get_seat_id() -> int:
		return _seat_id.value
	func clear_seat_id() -> void:
		_seat_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_seat_id(value : int) -> void:
		_seat_id.value = value
	
	var _pot: PBField
	func get_pot() -> int:
		return _pot.value
	func clear_pot() -> void:
		_pot.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_pot(value : int) -> void:
		_pot.value = value
	
	var _pot_ids: PBField
	func get_pot_ids() -> Array:
		return _pot_ids.value
	func clear_pot_ids() -> void:
		_pot_ids.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func add_pot_ids(value : int) -> void:
		_pot_ids.value.append(value)
	
	var _chips: PBField
	func get_chips() -> int:
		return _chips.value
	func clear_chips() -> void:
		_chips.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_chips(value : int) -> void:
		_chips.value = value
	
	func to_string() -> String:
		return PBPacker.message_to_string(data)
		
	func to_bytes() -> PoolByteArray:
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes : PoolByteArray, offset : int = 0, limit : int = -1) -> int:
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
################ USER DATA END #################
