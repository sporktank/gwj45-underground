extends Node


var _disable_buttons := false

onready var scenic_view := $UI/ScenicView
onready var main_menu := $UI/MainMenuScreen
onready var help_screen := $UI/HelpScreen


func _on_MainMenuScreen_start_button_pressed() -> void:
	if _disable_buttons:
		return
	
	_disable_buttons = true
	main_menu.hide()
	scenic_view.scroll(false)
	yield(scenic_view.tween, "tween_all_completed")
	
	
	
	_disable_buttons = false


func _on_MainMenuScreen_settings_button_pressed() -> void:
	if _disable_buttons:
		return
	
	help_screen.show()
