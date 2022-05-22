extends Node2D
class_name Game


const LOOT_TEXT := [
	"",
	"An old coin with a monkey on it! This was probably very valuable in the past.. but not any more.",
	"Very fancy! Not for drinking orange juice from though..",
	"JACKPOT!!!! now that's a cool skull, though a little scary...",
]

var time_played := 0.0
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
onready var mine := $Container/Mine as Mine

onready var tween := $Tween
onready var overlay := $Overlay
onready var black := $Overlay/Black


func _ready() -> void:
	Events.connect("lizard_died", self, "_on_lizard_died")
	Events.connect("loot_found", self, "_on_loot_found")
	Events.connect("snake_died", self, "_on_snake_died")
	Events.connect("snake_won", self, "_on_snake_won")
	
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
	time_played += delta
	_update_camera()


func fade_in() -> void:
	black.visible = true
	black.modulate.a = 1.0
	tween.interpolate_property(black, "modulate:a", 1.0, 0.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_snake_died(snake: Snake) -> void:
	black.visible = true
	black.modulate.a = 0.0
	yield(get_tree().create_timer(2), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	black.visible = false
	Events.emit_signal("game_over", {
		treasure_collected=mine.treasure_collected,
		treasure_value=mine.treasure_value_collected,
		snake_length=snake.get_length(),
		mines_identified=mine.get_correct_mine_count(),
		depth_reached=mine.get_depth_mined(),
		time_played=time_played,
		success=snake.state == Enums.SNAKE_STATE.WON,
	})


func _on_snake_won(snake: Snake) -> void:
	black.visible = true
	black.modulate.a = 0.0
	yield(get_tree().create_timer(2), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	yield(get_tree().create_timer(1), "timeout")
	
	black.visible = false
	Events.emit_signal("game_over", {
		treasure_collected=mine.treasure_collected,
		treasure_value=mine.treasure_value_collected,
		snake_length=snake.get_length(),
		mines_identified=mine.get_correct_mine_count(),
		depth_reached=mine.get_depth_mined(),
		time_played=time_played,
		success=snake.state == Enums.SNAKE_STATE.WON,
	})


func _update_camera() -> void:
	#camera.goal_y += 20 * (int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))); return
	match state:
		Enums.GAME_STATE.MINESWEEPER:
			camera.goal_y = lizard.global_position.y - Global.BLOCK_SIZE/2
		
		Enums.GAME_STATE.SNAKE:
			#camera.goal_y = snake.head.global_position.y - Global.BLOCK_SIZE/2
			camera.goal_y = snake.head_center_position.y


func change_to_snake_game() -> void:
	
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
	yield(get_tree().create_timer(2), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 1.0, 0.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	yield(get_tree().create_timer(2), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	Events.emit_signal("game_transition_ready")
	black.visible = false
	#change_to_snake_game()


func _on_loot_found(loot: int) -> void:
	if not show_loot_overlay[loot]:
		return
	
	show_loot_overlay[loot] = false
	
	var screen := Scenes.LOOT_SCREEN.instance() as LootScreen
	screen.loot_value = loot
	screen.text = LOOT_TEXT[loot]
	overlay.add_child(screen)
	get_tree().paused = true
