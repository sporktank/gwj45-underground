extends Control


signal start_button_pressed()
signal settings_button_pressed()


func _on_StartButton_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_SettingsButton_pressed() -> void:
	emit_signal("settings_button_pressed")
