extends Node2D


var skip_tutorial := false

onready var tween := $Tween
onready var lizard := $Lizard
onready var bird := $Bird
onready var snake := $Snake
onready var black := $Black


#func _ready() -> void: play_intro(0)
#func _ready() -> void: play_transition(0)


# ----- TRANSITION -----

func play_transition(delay: float) -> void:
	#Events.emit_signal("transition_finished") ; queue_free()
	
	lizard.visible = false
	snake.visible = true
	black.visible = false
	bird.visible = true
	bird.position = Vector2(610, 264)
	bird.play("perch")
	snake.play("lay")
	black.visible = true
	black.modulate.a = 1.0
	
	yield(get_tree().create_timer(delay), "timeout")
	
	tween.interpolate_property(black, "modulate:a", 1, 0, 2, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	
	yield(get_tree().create_timer(0.2), "timeout")
	bird.play("speak")
	var dialog = Dialogic.start("transition") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_transition_end")

func _on_transition_end(timeline_name: String) -> void:
	snake.play("rise")
	bird.play("perch")
	yield(get_tree().create_timer(0.2), "timeout")
	snake.play("rise")
	yield(get_tree().create_timer(1.0), "timeout")
	
	bird.play("speak")
	var dialog = Dialogic.start("transition2") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_transition2_end")

func _on_transition2_end(timeline_name: String) -> void:
	bird.play("perch")
	yield(get_tree().create_timer(0.2), "timeout")
	
	snake.play("speak")
	var dialog = Dialogic.start("transition3") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_transition3_end")

func _on_transition3_end(timeline_name: String) -> void:
	snake.play("slither")
	yield(get_tree().create_timer(1.0), "timeout")
	black.visible = true
	tween.interpolate_property(black, "modulate:a", 0, 1, 2, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	Events.emit_signal("transition_finished")
	queue_free()

# ----------


# ----- INTRO -----

func play_intro(delay: float) -> void:
	#Events.emit_signal("intro_finished") ; queue_free()
	
	lizard.visible = false
	snake.visible = false
	black.visible = false
	bird.visible = false
	
	yield(get_tree().create_timer(delay), "timeout")
	bird.visible = true
	bird.position = Vector2(812, -64)
	lizard.visible = true
	lizard.position = Vector2(112, 357)
	
	bird.play("fly")
	lizard.play("run")
	tween.interpolate_property(lizard, "position", Vector2(112, 357), Vector2(309, 357), 2, Tween.TRANS_LINEAR)
	tween.interpolate_property(bird, "position", Vector2(812, -64), Vector2(610, 264), 2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	bird.play("perch")
	lizard.stop()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	bird.play("speak")
	var dialog = Dialogic.start("intro") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_intro_end")
	dialog.connect("dialogic_signal", self, "_on_intro_signal")

func _on_intro_signal(argument: String) -> void:
	skip_tutorial = argument == "yes"

func _on_intro_end(timeline_name: String) -> void:
	if skip_tutorial:
		play_no_tutorial()
	else:
		play_tutorial()

func play_no_tutorial() -> void:
	var dialog = Dialogic.start("no_tutorial") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_no_tutorial_end")

func _on_no_tutorial_end(timeline_name: String) -> void:
	play_start_game()

func play_tutorial() -> void:
	var dialog = Dialogic.start("tutorial") ; add_child(dialog)
	dialog.connect("timeline_end", self, "_on_tutorial_end")

func _on_tutorial_end(timeline_name: String) -> void:
	play_start_game()

func play_start_game() -> void:
	bird.play("perch")
	lizard.play("run")
	tween.interpolate_property(lizard, "position", Vector2(309, 357), Vector2(593, 357), 2, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	lizard.stop()
	black.visible = true
	tween.interpolate_property(black, "modulate:a", 0, 1, 2, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	Events.emit_signal("intro_finished")
	queue_free()

# ----------
