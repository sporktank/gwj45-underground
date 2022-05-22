extends ColorRect


const TEXT := """treasure collected: %d
treasure value: $%d
length of snake: %d
mines correctly identified: %d
depth reached: %d
time played: %d:%0d

%s"""
const SUCCESS := "Enjoy the spoils of victory!"
const FAILURE := "But unfortuately you didn't make it out alive!"


onready var label := $Scores


func _on_BackButton_pressed() -> void:
	get_tree().reload_current_scene()  # HAcky gamejame stuff.


func set_data(stats) -> void:
	label.text = TEXT % [
		stats.treasure_collected,
		stats.treasure_value,
		stats.snake_length,
		stats.mines_identified,
		stats.depth_reached,
		int(floor(stats.time_played / 60)),
		int(int(stats.time_played) % 60),
		SUCCESS if stats.success else FAILURE
	]
