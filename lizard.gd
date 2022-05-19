extends Node2D
class_name Lizard


export(float) var walk_duration := 0.3
export(bool) var can_mine_self := true
export(int) var max_mine_distance := 2
export(int) var max_mine_distance_diag := 1
export(bool) var automine_zero_blocks := true
export(bool) var automine_zero_block_neighbours := true
export(bool) var can_double_mine := false

export(Enums.LIZARD_STATE) var state: int = Enums.LIZARD_STATE.IDLE
var direction := Vector2.RIGHT
var grid_position := Vector2.ZERO
var selector_grid_position: Vector2
var attack_position: Vector2

onready var debug_label := $Debug
onready var walk_tween := $WalkTween
onready var anim := $AnimatedSprite
onready var raycast_left := $RayCasts/Left
onready var raycast_right := $RayCasts/Right
onready var raycast_up := $RayCasts/Up
onready var raycast_down := $RayCasts/Down
onready var selector_pivot := $SelectorPivot


func _ready() -> void:
	selector_pivot.set_as_toplevel(true)
	
	_update_grid_position()
	_update_anim()


func _process(delta: float) -> void:
	if state == Enums.LIZARD_STATE.IDLE: 
		_check_for_state_change()
	
	_update_selector()
	_update_debug_label()


func _update_debug_label() -> void:
	debug_label.text = "state=%s\ndirection=%s\nraycasts(lrud)=%s%s%s%s\ngrid=%s\nselector=%s" % [
		state, direction,
		int(raycast_left.is_colliding()), int(raycast_right.is_colliding()),
		int(raycast_up.is_colliding()), int(raycast_down.is_colliding()),
		grid_position, selector_grid_position
	]


func _update_selector() -> void:
	selector_pivot.global_position = ((get_global_mouse_position() - Vector2(32, 48)) / Global.BLOCK_SIZE).round() * Global.BLOCK_SIZE + Vector2(0, 16) + Vector2(32, 32)
	selector_grid_position = ((selector_pivot.position - Vector2(0, 16) - Vector2(32, 32)) / Global.BLOCK_SIZE).round()
	
	var diff := (grid_position - selector_grid_position).abs()
	var dist: int = int(diff.x + diff.y)
	var dist_diag: int = int(max(diff.x, diff.y))
	
#	if can_mine_self and dist == 0:
#		selector_pivot.scale = 2.0 * Vector2.ONE
#	else:
#		selector_pivot.scale = Vector2.ONE
	
	if dist <= max_mine_distance and dist_diag <= max_mine_distance_diag and not state == Enums.LIZARD_STATE.DEAD:
		if dist == 0 and not can_mine_self:
			selector_pivot.visible = false
		else:
			selector_pivot.visible = true
	else:
		selector_pivot.visible = false


func _update_grid_position() -> void:
	grid_position = ((position - Vector2(0, 64)) / Global.BLOCK_SIZE).round()


func _check_for_state_change() -> void:
	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
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
		attack_position = grid_position + direction
		_attack()
		return
	if Input.is_action_just_pressed("mouse_attack"):
		if selector_pivot.visible:
			direction = (selector_grid_position - grid_position)
			if direction.length() > 1:
				direction.y = 0.0
			attack_position = selector_grid_position
			_attack()
			return
	
	if Input.is_action_just_pressed("flag"):
		attack_position = grid_position + direction
		_flag()
		return
	if Input.is_action_just_pressed("mouse_flag"):
		if selector_pivot.visible:
			direction = (selector_grid_position - grid_position)
			if direction.length() > 1:
				direction.y = 0.0
			attack_position = selector_grid_position
			_flag()
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
		Tween.TRANS_LINEAR,
		#Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	walk_tween.start()
	state = Enums.LIZARD_STATE.WALK
	_update_anim()


func _attack() -> void:
	state = Enums.LIZARD_STATE.ATTACK
	_update_anim()


func _flag() -> void:
	state = Enums.LIZARD_STATE.FLAG
	_update_anim()


func _update_anim() -> void:
	var anim_string := ""
	
	match state:
		Enums.LIZARD_STATE.IDLE: anim_string = "idle_"
		Enums.LIZARD_STATE.WALK: anim_string = "walk_"
		Enums.LIZARD_STATE.ATTACK: anim_string = "attack_"
		Enums.LIZARD_STATE.FLAG: anim_string = "attack_"  # NOTE: Re-using animation.
	
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
	
	else:
		anim_string += "down"
	
	anim.play(anim_string)


func _on_AnimatedSprite_animation_finished() -> void:
	match state:
		Enums.LIZARD_STATE.ATTACK, Enums.LIZARD_STATE.FLAG: 
			_check_for_state_change()


func _on_AnimatedSprite_frame_changed() -> void:
	
	if state == Enums.LIZARD_STATE.ATTACK and anim.frame == 2: # ?!?!
		Events.emit_signal("lizard_attacked", self, int(attack_position.x), int(attack_position.y))
	
	if state == Enums.LIZARD_STATE.FLAG and anim.frame == 2: # ?!?!
		Events.emit_signal("lizard_flagged", self, int(attack_position.x), int(attack_position.y))


func _on_WalkTween_tween_all_completed() -> void:
	_update_grid_position()
	_check_for_state_change()
