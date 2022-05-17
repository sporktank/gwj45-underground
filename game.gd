extends Node2D


onready var lizard := $Lizard


func _ready() -> void:
	remove_child(lizard)
	$Mine/YSort.add_child(lizard)


func _process(delta: float) -> void:
	$Camera.global_position.y = lizard.global_position.y + Global.BLOCK_SIZE/2 # TEMP
