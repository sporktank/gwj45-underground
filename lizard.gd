extends Node2D
class_name Lizard


export(float) var walk_speed := 128.0

var state: int = Enums.LIZARD_STATE.IDLE
var direction := Vector2.RIGHT
var input_dir := Vector2.ZERO
var initial_position := Vector2.ZERO

onready var debug_label := $Debug
onready var anim := $AnimatedSprite


func _physics_process(delta: float) -> void:
	
	var previous_state := state
	var next_state: int = Enums.LIZARD_STATE.INVALID
	
	input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)#.clamped(1.0)
	
	match state:
		Enums.LIZARD_STATE.IDLE: next_state = idle(delta)
		Enums.LIZARD_STATE.WALK: next_state = walk(delta)
	
	update_anim()
	
	if next_state != Enums.LIZARD_STATE.INVALID and next_state != previous_state:
		state = next_state
	
	_update_debug_label()


func _update_debug_label() -> void:
	debug_label.text = "state=%s\ndirection=%s" % [state, direction]


func snap_to_grid() -> void:
	position = (position / Global.BLOCK_SIZE).round() * Global.BLOCK_SIZE


func update_anim() -> void:
	var anim_string := ""
	
	match state:
		Enums.LIZARD_STATE.IDLE: anim_string = "idle_"
		Enums.LIZARD_STATE.WALK: anim_string = "walk_"
	
	if direction == Vector2.LEFT: 
		anim_string += "left"
		anim.flip_h = false
	
	elif direction == Vector2.RIGHT: 
		anim_string += "left"
		anim.flip_h = true
	
	elif direction == Vector2.UP: 
		anim_string += "up"
	
	elif direction == Vector2.DOWN: 
		anim_string += "down"
	
	anim.play(anim_string)


func idle(delta: float) -> int:
	
	if input_dir != Vector2.ZERO:
		if input_dir.x < 0:
			direction = Vector2.LEFT
		elif input_dir.x > 0:
			direction = Vector2.RIGHT
		elif input_dir.y < 0:
			direction = Vector2.UP
		elif input_dir.y > 0:
			direction = Vector2.DOWN
		
		initial_position = position
		return Enums.LIZARD_STATE.WALK
	
	return Enums.LIZARD_STATE.IDLE


func walk(delta: float) -> int:
	
	position += direction * walk_speed * delta
	
	if position.distance_to(initial_position) > Global.BLOCK_SIZE:
		snap_to_grid()
		return idle(delta)  # ?!?!
	
	return Enums.LIZARD_STATE.INVALID
