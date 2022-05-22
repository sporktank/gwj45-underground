extends Node


var _disable_buttons := false
var game: Game

onready var ui := $UI
onready var scenic_view := $UI/ScenicView
onready var main_menu := $UI/MainMenuScreen
onready var help_screen := $UI/HelpScreen
onready var scores_screen := $UI/ScoresScreen
onready var game_container := $GameContainer

onready var music1 := $Audio/Music1
onready var music2 := $Audio/Music2


func _ready() -> void:
	Events.connect("intro_finished", self, "_on_intro_finished")
	Events.connect("game_transition_ready", self, "_on_game_transition_ready")
	Events.connect("transition_finished", self, "_on_transition_finished")
	Events.connect("game_over", self, "_on_game_over")
	
	music1.play()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("mouse_attack") and help_screen.visible:
		help_screen.visible = false
		get_tree().set_input_as_handled()


func _on_MainMenuScreen_start_button_pressed() -> void:
	main_menu.hide()
	scenic_view.scroll(false)
	var intro := Scenes.CUTSCENE.instance()
	ui.add_child(intro)
	intro.play_intro(5)


func _on_MainMenuScreen_settings_button_pressed() -> void:
	help_screen.show()


func _on_intro_finished() -> void:
	game = Scenes.GAME.instance()
	game_container.add_child(game)
	scenic_view.hide()
	game.fade_in()


func _on_game_transition_ready() -> void:
	var transition := Scenes.CUTSCENE.instance()
	ui.add_child(transition)
	scenic_view.show()
	transition.play_transition(0)


func _on_transition_finished() -> void:
	game.change_to_snake_game()
	scenic_view.hide()
	game.fade_in()
	music1.stop()
	music2.play()


func _on_game_over(stats: Dictionary) -> void:
	scenic_view.show()
	scores_screen.set_data(stats)
	scores_screen.show()
	game.queue_free()
	#music1.play()
	#music2.stop()
