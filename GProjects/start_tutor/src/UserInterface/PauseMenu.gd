extends Control


export(Vector2) var _start_position = Vector2(0, -20)
export(Vector2) var _end_position = Vector2.ZERO
export(float) var fade_in_duration = 0.3
export(float) var fade_out_duration = 0.2

onready var center_cont = $ColorRect/CenterContainer
onready var resume_button = center_cont.get_node(@"VBoxContainer/ResumeButton")

onready var timer = get_parent().get_parent().get_node("GameTimer")
onready var timer_label = get_parent().get_node("TimerLabel")

onready var root = get_tree().get_root()
onready var scene_root = root.get_child(root.get_child_count() - 1)
onready var tween = $Tween


func _ready():
	hide()


func close():
	timer_label.show()
	get_tree().paused = false
	# Tween's interpolate_property has these arguments:
	# (Target object, "Property:OptionalSubProperty", From value, To value,
	# Tween duration, Transition type, Easing type, Optional delay)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0,
			fade_out_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(center_cont, "rect_position",
			_end_position, _start_position, fade_out_duration,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func open():
	timer_label.hide()
	show()
	resume_button.grab_focus()

	tween.interpolate_property(self, "modulate:a", 0.0, 1.0,
			fade_in_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(center_cont, "rect_position",
			_start_position, _end_position, fade_in_duration,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func _on_ResumeButton_pressed():
	if not tween.is_active():
		timer.set_paused(false)
		close()


func _on_QuitButton_pressed():
	get_tree().paused = not get_tree().paused
	get_tree().change_scene("res://src/UserInterface/StartMenu.tscn")
	get_tree().set_input_as_handled()


func _on_Tween_all_completed():
	if modulate.a < 0.5:
		hide()
