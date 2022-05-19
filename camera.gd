extends Camera2D


export(float) var goal_y := 0.0
export(float) var soft_limit := 64.0
export(float) var hard_limit := 96.0
export(float) var speed := 64/0.3

var _goal_velocity := 0.0
var _velocity := 0.0


func _process(delta: float) -> void:
	var diff := goal_y - global_position.y
	
	if abs(diff) > hard_limit:
		_goal_velocity = sign(diff) * speed
	
	elif abs(diff) < soft_limit:
		_goal_velocity = 0.0
	
	_velocity = lerp(_velocity, _goal_velocity, 0.5 if _goal_velocity != 0.0 else 0.05)
	translate(Vector2(0, _velocity * delta))
