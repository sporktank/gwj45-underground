extends Node2D
class_name LootEffect


var duration := 1.0
var text := ""
var velocity := 0.0
var _time := 0.0

onready var label := $Label


func _process(delta: float) -> void:
	label.text = text
	translate(Vector2(0, velocity * delta))
	_time += delta
	modulate.a = clamp(2 - 2 * _time/duration, 0, 1)
	if _time > duration:
		queue_free()
