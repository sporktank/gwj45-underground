extends Node2D
class_name Lizard


export(float) var walk_duration := 0.3

var state: int = Enums.LIZARD_STATE.IDLE
var direction := Vector2.RIGHT
var input_dir := Vector2.ZERO
var grid_position := Vector2.ZERO

onready var debug_label := $Debug
onready var walk_tween := $WalkTween
onready var anim := $AnimatedSprite
onready var raycast_left := $RayCasts/Left
onready var raycast_right := $RayCasts/Right
onready var raycast_up := $RayCasts/Up
onready var raycast_down := $RayCasts/Down


func _ready() -> void:
	_update_grid_position()
	_update_anim()


func _process(delta: float) -> void:
	
	var previous_state := state
	var next_state: int = Enums.LIZARD_STATE.INVALID
	
	input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)#.clamped(1.0)
	
	if state == Enums.LIZARD_STATE.IDLE: 
		_check_for_state_change()
	
	_update_debug_label()


func _update_debug_label() -> void:
	debug_label.text = "state=%s\ndirection=%s\nraycasts(lrud)=%s%s%s%s\ngrid=%s" % [
		state, direction,
		int(raycast_left.is_colliding()), int(raycast_right.is_colliding()),
		int(raycast_up.is_colliding()), int(raycast_down.is_colliding()),
		grid_position
	]


func _update_grid_position() -> void:
	grid_position = (position / Global.BLOCK_SIZE).round()


func _check_for_state_change() -> void:
	
	if input_dir.x < 0:
		direction = Vector2.LEFT
		if not raycast_left.is_colliding():
			_walk()
			return
		
	if input_dir.x > 0:
		direction = Vector2.RIGHT
		if not raycast_right.is_colliding():
			_walk()
			return
	
	if input_dir.y < 0:
		direction = Vector2.UP
		if not raycast_up.is_colliding():
			_walk()
			return
	
	if input_dir.y > 0:
		direction = Vector2.DOWN
		if not raycast_down.is_colliding():
			_walk()
			return
	
	if Input.is_action_just_pressed("attack"):
		_attack()
		return
	
	_idle()


func _idle() -> void:
	state = Enums.LIZARD_STATE.IDLE
	_update_anim()


func _walk() -> void:
	walk_tween.interpolate_property(
		self, 
		"position", 
		position, 
		position + direction * Global.BLOCK_SIZE, 
		walk_duration, 
		#Tween.TRANS_LINEAR,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	walk_tween.start()
	state = Enums.LIZARD_STATE.WALK
	_update_anim()


func _attack() -> void:
	state = Enums.LIZARD_STATE.ATTACK
	_update_anim()


func _update_anim() -> void:
	var anim_string := ""
	
	match state:
		Enums.LIZARD_STATE.IDLE: anim_string = "idle_"
		Enums.LIZARD_STATE.WALK: anim_string = "walk_"
		Enums.LIZARD_STATE.ATTACK: anim_string = "attack_"
	
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


func _on_AnimatedSprite_animation_finished() -> void:
	match state:
		Enums.LIZARD_STATE.ATTACK: 
			_check_for_state_change()


func _on_AnimatedSprite_frame_changed() -> void:
	if state == Enums.LIZARD_STATE.ATTACK and anim.frame == 2: # ?!?!
		Events.emit_signal("lizard_attacked", self, int(grid_position.x + direction.x), int(grid_position.y + direction.y))


func _on_WalkTween_tween_all_completed() -> void:
	_update_grid_position()
	_check_for_state_change()
