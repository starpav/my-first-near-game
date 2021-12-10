extends Node
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.


# The "_" prefix is a convention to indicate that variables are private,
# that is to say, another node or script should not access them.
onready var _pause_menu = $InterfaceLayer/PauseMenu
onready var _game_over_menu = $InterfaceLayer/GameOverMenu
onready var _player = $Level/Player

var time = 40

func _init():
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()


func _ready():
	$GameTimer.set_wait_time(time)
	$GameTimer.set_autostart(true)
	$GameTimer.set_one_shot(true)


func _process(delta):
	time = $GameTimer.get_time_left()
	var mils = fmod(time, 1) * 1000
	var secs = fmod(time, 60)
	var time_passed = "%02d : %03d" % [secs, mils]
	$InterfaceLayer/TimerLebel.set_text(time_passed)


func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		# We need to clean up a little bit first to avoid Viewport errors.
		if name == "Splitscreen":
			$Black/SplitContainer/ViewportContainer1.free()
			$Black.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
	# The GlobalControls node, in the Stage scene, is set to process even
	# when the game is paused, so this code keeps running.
	# To see that, select GlobalControls, and scroll down to the Pause category
	# in the inspector.
	elif event.is_action_pressed("toggle_pause"):
		var tree = get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
			$GameTimer.set_paused(true)
		else:
			_pause_menu.close()
			$GameTimer.set_paused(false)
		get_tree().set_input_as_handled()


func _on_GameTimer_timeout():
	var tree = get_tree()
	tree.paused = not tree.paused
	if tree.paused:
		_game_over_menu.open()
	get_tree().set_input_as_handled()
