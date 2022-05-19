extends Node2D


var state: int = Enums.GAME_STATE.MINESWEEPER

onready var camera := $Camera as Camera2D
onready var lizard := $Lizard as Lizard
onready var snake := $Snake as Snake


func _ready() -> void:
	Events.connect("lizard_died", self, "_on_lizard_died")
	
	remove_child(lizard) ; $Mine/YSort.add_child(lizard)
	remove_child(snake) ; $Mine/YSort.add_child(snake)
	snake.init_snake(Vector2.ZERO, Vector2.DOWN, 3)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode == KEY_F2 and event.is_pressed() and not event.is_echo():
		_change_to_snake_game()


func _process(delta: float) -> void:
	_update_camera()


func _update_camera() -> void:
	match state:
		Enums.GAME_STATE.MINESWEEPER:
			camera.goal_y = lizard.global_position.y - Global.BLOCK_SIZE/2
		
		Enums.GAME_STATE.SNAKE:
			camera.goal_y = snake.head.global_position.y - Global.BLOCK_SIZE/2


func _change_to_snake_game() -> void:
	lizard.state = Enums.LIZARD_STATE.DEAD
	lizard.visible = false
	snake.state = Enums.SNAKE_STATE.STILL
	snake.position.y += Global.BLOCK_SIZE
	snake.visible = true
	state = Enums.GAME_STATE.SNAKE
	camera.goal_y = snake.head.global_position.y - Global.BLOCK_SIZE/2
	camera.global_position.y = camera.goal_y


func _on_lizard_died(lizard: Lizard) -> void:
	_change_to_snake_game()
