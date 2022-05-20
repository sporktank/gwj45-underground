extends Camera2D


export(float) var goal_y := 0.0
export(float) var soft_limit := 32.0
export(float) var hard_limit := 128.0
export(float) var speed := 64/0.3 #* 2

var _goal_velocity := 0.0
var _velocity := 0.0


func _process(delta: float) -> void:
	global_position.y = clamp(lerp(global_position.y, goal_y, 0.8), 270 - 16, INF)
	
	#var diff := clamp(clamp(lerp(global_position.y, goal_y, 0.8), 270 - 16, INF) - global_position.y , -50, 50)
	#global_position.y += diff


#func _process(delta: float) -> void:
#	var diff := goal_y - global_position.y
#
#	if abs(diff) > hard_limit:
#		_goal_velocity = sign(diff) * speed
#
#	elif abs(diff) < soft_limit:
#		_goal_velocity = 0.0
#
#	_velocity = lerp(_velocity, _goal_velocity, 0.5 if _goal_velocity != 0.0 else 0.05)
#	translate(Vector2(0, _velocity * delta))
