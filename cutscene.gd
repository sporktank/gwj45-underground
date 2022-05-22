extends Node2D


var skip_tutorial := false

onready var tween := $Tween
onready var lizard := $Lizard
onready var bird := $Bird
onready var snake := $Snake
onready var black := $Black


func _ready() -> void:
	play_intro()


# ----- INTRO -----

func play_intro() -> void:
	lizard.visible = true
	bird.visible = true
	snake.visible = false
	black.visible = false
	
	bird.play("fly")
	tween.interpolate_property(bird, "position", Vector2(812, -64), Vector2(610, 264), 4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	bird.play("perch")
	
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

# ----------
