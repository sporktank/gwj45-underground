extends ColorRect


var loot_value := 0
var text := "WOW! An old artifact! Too bad I didn't bring my backpack."

onready var sunburst := $Sunburst
onready var sprite := $Sprite
onready var text_label := $Text


func _ready() -> void:
	sprite.frame = loot_value
	text_label.text = text


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("mouse_attack"):
		#yield(get_tree(), "idle_frame")
		yield(get_tree().create_timer(0.05), "timeout")
		get_tree().paused = false
		queue_free()


func _process(delta: float) -> void:
	sunburst.rotate(deg2rad(360.0/5) * delta)
