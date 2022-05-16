extends Node2D


func _process(delta: float) -> void:
	$Camera.global_position.y = $Lizard.global_position.y + Global.BLOCK_SIZE/2 # TEMP
