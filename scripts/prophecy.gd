extends Control

@export var nodes_paths:Array[NodePath]

var knock_knock = 0

#sounds
var knock_sound = preload("res://assets/sfx/knock_knock.wav")
var prophecy_calculating = preload("res://assets/sfx/laugh_01.wav")
var prophecy_finished = preload("res://assets/sfx/1054.wav")

#cursors
var hand_cursor = preload("res://assets/cursors/hand_knock.png")
var arrow_cursor = preload("res://assets/cursors/hand_normal.png")

#reaction texts
var reaction_text = [
	"she might not be awake",
	"reaction time enganged",
	"swat time active"
]

func _ready():
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(20,20))
	Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_POINTING_HAND, Vector2(24,24))
	$AnimationPlayer.play("intro_fade-in")
	
	var buttons = get_tree().get_nodes_in_group("buttons")
	for i in buttons:
		i.focus_mode = FOCUS_NONE
		i.mouse_default_cursor_shape = CURSOR_POINTING_HAND

func _play_sfx(sfx):
	$sounds.stream = sfx
	$sounds.play()

	#stage 0 ----------
#knock knock
func _on_knock_button_pressed():
	var button = get_node(nodes_paths[4])
	if knock_knock == 3:
		knock_knock = 0
		$prophecy_stages.current_tab = 1
		_play_sfx(prophecy_calculating)
	else:
		get_node(nodes_paths[3]).value = 100
		_play_sfx(knock_sound)
		button.disabled = true
		get_node(nodes_paths[2]).start()
		knock_knock += 1
		_print_reaction()

func _on_knock_timer_timeout():
	var knock_bar = get_node(nodes_paths[3])
	if knock_bar.value > 0:
		knock_bar.value -= 2
	else:
		get_node(nodes_paths[4]).disabled = false
		get_node(nodes_paths[2]).stop()
		if knock_knock == 3:
			get_node(nodes_paths[4]).text = "enter"
			knock_bar.self_modulate = Color(1,1,1,0)
			_play_sfx(prophecy_calculating)

func _print_reaction():
	reaction_text.shuffle()
	get_node(nodes_paths[5]).text = reaction_text.front()
	reaction_text.pop_front()

#---------- stage 0

func _on_prophecy_timer_timeout():
	var prophecy_bar = get_node(nodes_paths[0])
	if prophecy_bar.value >= 100:
		_prophecy_complete()
	else:
		prophecy_bar.value += 1

func _prophecy_complete():
	_play_sfx(prophecy_finished)
	get_node(nodes_paths[1]).stop()
	$prophecy_stages.current_tab = 2
	



