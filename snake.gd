extends YSort
class_name Snake


export(float) var move_duration := 0.3

export(Enums.SNAKE_STATE) var state: int = Enums.SNAKE_STATE.INACTIVE
var is_moving := false
var direction := Vector2.DOWN
var next_direction := Vector2.DOWN

var head_center_position: Vector2

var head: SnakePiece = null
var tail: SnakePiece = null

var _grow_amount := 0

onready var move_tween := $MoveTween
onready var pieces := $Pieces
onready var raycasts := $RayCasts
onready var raycast_left := $RayCasts/Left
onready var raycast_right := $RayCasts/Right
onready var raycast_up := $RayCasts/Up
onready var raycast_down := $RayCasts/Down


#func _ready() -> void:
#	init_snake(Vector2.ZERO, Vector2.DOWN, 5)
#	state = Enums.SNAKE_STATE.STILL


func _process(delta: float) -> void:
	match state:
		Enums.SNAKE_STATE.INACTIVE:
			return
		
		Enums.SNAKE_STATE.STILL:
			# Be more forgiving on first move.
			if Input.is_action_just_pressed("up") and direction != Vector2.DOWN and not raycast_up.is_colliding():
				_move(Vector2.UP)
			elif Input.is_action_just_pressed("down") and direction != Vector2.UP and not raycast_down.is_colliding():
				_move(Vector2.DOWN)
			elif Input.is_action_just_pressed("left") and direction != Vector2.RIGHT and not raycast_left.is_colliding():
				_move(Vector2.LEFT)
			elif Input.is_action_just_pressed("right") and direction != Vector2.LEFT and not raycast_right.is_colliding():
				_move(Vector2.RIGHT)
		
		Enums.SNAKE_STATE.MOVING:
			if is_moving:
				if Input.is_action_pressed("up") and direction != Vector2.DOWN:
					next_direction = Vector2.UP
				elif Input.is_action_pressed("down") and direction != Vector2.UP:
					next_direction = Vector2.DOWN
				elif Input.is_action_pressed("left") and direction != Vector2.RIGHT:
					next_direction = Vector2.LEFT
				elif Input.is_action_pressed("right") and direction != Vector2.LEFT:
					next_direction = Vector2.RIGHT
			
			else:
				if _check_for_death(next_direction):
					state = Enums.SNAKE_STATE.DEAD
				else:
					_move(next_direction, _grow_amount > 0)
					if _grow_amount > 0: _grow_amount -= 1


func _check_for_death(new_direction: Vector2) -> bool:
	if new_direction == Vector2.UP and raycast_up.is_colliding(): return true
	if new_direction == Vector2.DOWN and raycast_down.is_colliding(): return true
	if new_direction == Vector2.LEFT and raycast_left.is_colliding(): return true
	if new_direction == Vector2.RIGHT and raycast_right.is_colliding(): return true
	return false


func init_snake(position: Vector2, start_direction: Vector2, length: int) -> void:
	for child in pieces.get_children():
		pieces.remove_child(child)
		child.queue_free()
	
	for i in length:
		var piece := Scenes.SNAKE_PIECE.instance() as SnakePiece
		pieces.add_child(piece)
		piece.position = position - start_direction * i * Global.BLOCK_SIZE
	
	for i in length-1:
		pieces.get_child(i + 0).next_piece = pieces.get_child(i + 1)
		pieces.get_child(i + 1).prev_piece = pieces.get_child(i + 0)
	
	for i in length:
		pieces.get_child(i).init_piece(start_direction)
	
	head = pieces.get_child(0)
	tail = pieces.get_child(length - 1)
	tail.collision_shape.disabled = true
	
	head_center_position = head.center.global_position


func grow(amount: int) -> void:
	_grow_amount += amount


func _move(new_direction: Vector2, grow_tail := false) -> void:
	if is_moving:
		return
	
	is_moving = true
	state = Enums.SNAKE_STATE.MOVING
	direction = new_direction
	next_direction = new_direction
	
	var new_head := Scenes.SNAKE_PIECE.instance() as SnakePiece
	new_head.position = head.position + direction * Global.BLOCK_SIZE
	new_head.next_piece = head
	head.prev_piece = new_head
	pieces.add_child(new_head)
	pieces.move_child(new_head, 0)
	head = new_head
	raycasts.position = head.position
	
	# Animate.
	for piece_ in pieces.get_children():
		var piece := (piece_ as SnakePiece)
		piece.animate_move(move_tween, grow_tail, move_duration)
	
	# Interpolate a reference to the visual center of the snake.
	move_tween.interpolate_property(self, "head_center_position", head.next_piece.center.global_position, head.center.global_position, move_duration, Tween.TRANS_LINEAR)
	
	move_tween.start()
	yield(move_tween, "tween_all_completed")
	
	# TODO: Probably should centralise this kind of logic somewhere.
	var grid_position = ((head.global_position - Vector2(0, 64)) / Global.BLOCK_SIZE).round()
	Events.emit_signal("snake_swallowed", self, int(grid_position.x), int(grid_position.y))
	
	if grow_tail:
		pass # Nothing to do?
	
	else:
		var old_tail := tail
		tail = tail.prev_piece
		tail.next_piece = null
		pieces.remove_child(old_tail)
		old_tail.queue_free()
		tail.collision_shape.disabled = true
	
	is_moving = false
