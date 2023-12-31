extends Control

@export var nodes_paths:Array[NodePath]
@export var knock_speed:float
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

func _on_knock_button_pressed():
	var button = get_node(nodes_paths[4])
	if knock_knock == 3:
		knock_knock = 0
		$prophecy_stages.current_tab = 1
		_play_sfx(prophecy_calculating)
		get_node(nodes_paths[1]).start()
		
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
		knock_bar.value -= knock_speed
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


#stage 1 ----------

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
	_select_prophecy()

#---------- stage 1


#stage 2 ----------

func _select_prophecy():
	var random = randi_range(2,2)
	var method = var_to_str(random)
	match method:
		"1":
			_prophecy_word()
		"2":
			$prophecy_stages/prophecy/Label.text = _prophecy_repeat()
		"3":
			_prophecy_sentence()
		_:
			print("no prophecy for you")

func _prophecy_word():
	print("word")
	
func _prophecy_repeat():
	print("repeat")
	var words_array = []
	var words_file = FileAccess.open("res://assets/texts/words.txt", FileAccess.READ)
	while not words_file.eof_reached():
		var line = words_file.get_line()
		words_array.append(line)
	words_file.close()
	words_array.pop_back()
	return words_array[0]
		
		
	

func _prophecy_sentence():
	print("sentence")

#---------- stage 2

#var words_lines = []
#	var content = words_file.get_as_text()
#	words_lines = content.split("\n")
#	words_file.close()
#	var random_line_index = randi() % words_lines.size()
#	return words_lines[random_line_index]
