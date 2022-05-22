extends Node2D


var _time := 0.0

onready var clouds := $Clouds
onready var tween := $Tween


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack"):
		scroll(false)


func _process(delta: float) -> void:
	_time += delta
	clouds.position.x = -10 + 10 * sin(_time * 0.35)
	

func scroll(out := false) -> void:
	tween.stop_all()
	tween.interpolate_property(
		self, 
		"position:y", 
		0 if out else 540,
		540 if out else 0,
		5.0,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	tween.start()
