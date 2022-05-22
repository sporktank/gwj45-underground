extends AnimatedSprite
class_name RockCrumble


func _ready() -> void:
	play()


func _on_RockCrumble_animation_finished() -> void:
	queue_free()
