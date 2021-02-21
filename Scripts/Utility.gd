const Model = preload("res://Scripts/Model.gd")


class Currency:
	static func get_currency(number) -> String:
		# Place the decimal separator
		var txt_numb: String = "%.2f" % number
		if txt_numb[-1] == txt_numb[-2] and txt_numb[-1] == "0":
			txt_numb = txt_numb.substr(0, txt_numb.length()-3)
			for idx in range(txt_numb.length() - 3, 0, -3):
				txt_numb = txt_numb.insert(idx, ",")
		else:
			# Place the thousands separator
			for idx in range(txt_numb.find(".") - 3, 0, -3):
				txt_numb = txt_numb.insert(idx, ",")
		return(txt_numb)


class Bet:
	static func get_bet_text(text: String) -> String:
		if text == "min":
			text = "Min"
		elif text == "max":
			text = "Max"
		elif text.find("/"):
			if text[0] == text[-1]:
				text = "Pot"
		return text

	static func get_bet_val(text:String):
		if text == "Min":
			return 0
		elif text == "Max":
			return 999
		elif text == "Pot":
			return 1
		else:
			return float(text[0]) / float(text[2])

class Table:
	static func spawn_position(n: int) -> Array:
		var active_pos:Array = []
		match n:
			2:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.BB]
			3:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB]
			4:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG]
			5:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG, Model.TABLE_POSITION.CO]
			6:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG, Model.TABLE_POSITION.HJ,
				Model.TABLE_POSITION.CO]
			7:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG, Model.TABLE_POSITION.UTG1,
				Model.TABLE_POSITION.HJ, Model.TABLE_POSITION.CO]
			8:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG, Model.TABLE_POSITION.UTG1,
				Model.TABLE_POSITION.UTG2, Model.TABLE_POSITION.HJ, Model.TABLE_POSITION.CO]
			9:
				active_pos = [Model.TABLE_POSITION.BTN, Model.TABLE_POSITION.SB,
				Model.TABLE_POSITION.BB, Model.TABLE_POSITION.UTG, Model.TABLE_POSITION.UTG1,
				Model.TABLE_POSITION.UTG2, Model.TABLE_POSITION.UTG3, Model.TABLE_POSITION.HJ, 
				Model.TABLE_POSITION.CO]
		return active_pos

