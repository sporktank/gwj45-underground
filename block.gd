extends Reference
class_name Block


var is_mine: bool = false
var is_border: bool = false
var number: int = 0
var solid: bool = false
var flagged: bool = false


func _init(is_mine: bool, is_border: bool, number: int, solid: bool, flagged: bool) -> void:
	self.is_mine = is_mine
	self.is_border = is_border
	self.number = number
	self.solid = solid
	self.flagged = flagged


func _to_string() -> String:
	return "W" if is_border else "x" if is_mine else str(number)
