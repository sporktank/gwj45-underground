extends Node2D


const LOOT_TEXT := [
	"",
	"An old coin with a monkey on it! This was probably worth heaps ages ago, but not any more.",
	"",
	"",
]

var state: int = Enums.GAME_STATE.MINESWEEPER
var show_loot_overlay := [
	null,
	true, # Enums.LOOT.TREASURE_1
	true, # Enums.LOOT.TREASURE_2
	true, # Enums.LOOT.TREASURE_3
]


onready var camera := $Container/Camera as Camera2D
onready var lizard := $Container/Lizard as Lizard
onready var snake := $Container/Snake as Snake

onready var tween := $Tween
onready var overlay := $Overlay
onready var black := $Overlay/Black


func _ready() -> void:
	Events.connect("lizard_died", self, "_on_lizard_died")
	Events.connect("loot_found", self, "_on_loot_found")
	
	remove_child(lizard) ; $Container/Mine/YSort.add_child(lizard)
	remove_child(snake) ; $Container/Mine/YSort.add_child(snake)
	snake.init_snake(Vector2.ZERO, Vector2.DOWN, 3)
	#camera.goal_y = lizard.global_position.y - Global.BLOCK_SIZE/2
	camera.goal_y = snake.head_center_position.y
	camera.global_position.y = camera.goal_y
	

#func _input(event: InputEvent) -> void:
#	if event is InputEventKey and event.scancode == KEY_F2 and event.is_pressed() and not event.is_echo():
#		_change_to_snake_game()


func _process(delta: float) -> void:
	_update_camera()


func _update_camera() -> void:
	#camera.goal_y += 20 * (int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))); return
	match state:
		Enums.GAME_STATE.MINESWEEPER:
			camera.goal_y = lizard.global_position.y - Global.BLOCK_SIZE/2
		
		Enums.GAME_STATE.SNAKE:
			#camera.goal_y = snake.head.global_position.y - Global.BLOCK_SIZE/2
			camera.goal_y = snake.head_center_position.y


func _change_to_snake_game() -> void:
	
	#lizard.state = Enums.LIZARD_STATE.DEAD
	#lizard.visible = false
	
	snake.state = Enums.SNAKE_STATE.STILL
	snake.position.y += Global.BLOCK_SIZE
	snake.visible = true
	
	camera.goal_y = snake.head.global_position.y - Global.BLOCK_SIZE/2
	#camera.global_position.y = camera.goal_y
	
	state = Enums.GAME_STATE.SNAKE


func _on_lizard_died(lizard: Lizard) -> void:
	
	#yield(get_tree().create_timer(0.05), "timeout")
	
	black.visible = true
	black.modulate.a = 1.0
	yield(get_tree().create_timer(2.5), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 1.0, 0.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	black.visible = false
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	_change_to_snake_game()


func _on_loot_found(loot: int) -> void:
	if not show_loot_overlay[loot]:
		return
	
	show_loot_overlay[loot] = false
	
	var screen := Scenes.LOOT_SCREEN.instance()
	screen.loot_value = loot
	screen.text = LOOT_TEXT[loot]
	overlay.add_child(screen)
	get_tree().paused = true
