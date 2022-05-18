extends Node2D
class_name SnakePiece


const NUM_FRAMES := 4

var prev_piece: SnakePiece = null
var next_piece: SnakePiece = null

onready var anim := $AnimatedSprite
onready var collision_shape = $StaticBody2D/CollisionShape2D


func is_head() -> bool:
	return prev_piece == null


func is_tail() -> bool:
	return next_piece == null


func _vec2_to_dir(v: Vector2) -> String:
	match v:
		Vector2.UP: return "up"
		Vector2.DOWN: return "down"
		Vector2.LEFT: return "left"
		Vector2.RIGHT: return "right"
	return ""


func animate_move(tween: Tween, grow_tail := false, duration := 0.3) -> void:
	
	if is_tail() and grow_tail:
		return
	
	var from_vec2 := (position - (next_piece.position if next_piece != null else position)).normalized()
	var to_vec2 := ((prev_piece.position if prev_piece != null else position) - position).normalized()
	
	var from_dir := _vec2_to_dir(from_vec2)
	var to_dir := _vec2_to_dir(to_vec2)
	
	# TODO: Handle length < 3.
	var anim_name := "empty"
	
	if is_head():
		anim_name = "head_%s" % [from_dir]
	
	elif prev_piece.is_head():
		anim_name = "head_%s_body_%s" % [from_dir, to_dir]
	
	elif is_tail():
		anim_name = "tail_%s" % [to_dir]
	
	elif next_piece.is_tail() and not grow_tail:
		anim_name = "body_%s_tail_%s" % [from_dir, to_dir]
	
	else:
		anim_name = "body_%s_body_%s" % [from_dir, to_dir]
	
	anim.animation = anim_name if anim_name in anim.frames.get_animation_names() else "empty"
	tween.interpolate_property(anim, "frame", 0, NUM_FRAMES - 1, duration)


func init_piece(direction: Vector2) -> void:
	var dir_str := _vec2_to_dir(direction)
	
	if is_head():
		anim.animation = "head_%s" % [dir_str]
	elif is_tail():
		anim.animation = "body_%s_tail_%s" % [dir_str, dir_str]
	else:
		anim.animation = "body_%s_body_%s" % [dir_str, dir_str]
	
	anim.frame = NUM_FRAMES - 1
