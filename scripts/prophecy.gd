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

var random_pics = [
		preload("res://_tests/1.png"),
		preload("res://_tests/2.png"),
		preload("res://_tests/3.png")
	]

#lists
var reactions_array = []
var words_array = []


func _ready():
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(20,20))
	Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_POINTING_HAND, Vector2(24,24))
	$AnimationPlayer.play("intro_fade-in")
	
	#load all words lists into arrays
	_load_file_list("res://assets/texts/reactions.txt", reactions_array)
	_load_file_list("res://assets/texts/words.txt", words_array)
	

	#apply settings for cursor and focus to all buttons
	var buttons = get_tree().get_nodes_in_group("buttons")
	for i in buttons:
		i.focus_mode = FOCUS_NONE
		i.mouse_default_cursor_shape = CURSOR_POINTING_HAND

func _load_file_list(file2open, array2append):
	var _file = FileAccess.open(file2open, FileAccess.READ)
	while not _file.eof_reached():
		var line = _file.get_line()
		array2append.append(line)
	_file.close()
	array2append.pop_back()

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
	reactions_array.shuffle()
	get_node(nodes_paths[5]).text = reactions_array.front()
	reactions_array.pop_front()

#---------- stage 0


#stage 1 ----------

func _on_prophecy_timer_timeout():
	random_pics.shuffle()
	var prophecy_bar = get_node(nodes_paths[0])
	var pic_selected = random_pics.front()
	if prophecy_bar.value >= 100:
		_prophecy_complete()
	else:
		prophecy_bar.value += 1
	$prophecy_stages/encounter/TextureRect.texture = pic_selected
	
func _prophecy_complete():
	_play_sfx(prophecy_finished)
	get_node(nodes_paths[1]).stop()
	$prophecy_stages.current_tab = 2
	_select_prophecy()

#---------- stage 1


#stage 2 ----------

func _select_prophecy():
	var random = randi_range(1,2)
	var method = var_to_str(random)
	match method:
		"1":
			$prophecy_stages/prophecy/Label.text = _prophecy_word()
		"2":
			$prophecy_stages/prophecy/Label.text = _prophecy_or()
		"3":
			_prophecy_sentence()
		_:
			print("no prophecy for you")

func _prophecy_word():
	print("word")
	var chosen
	var more_less_add = randi_range(0,2)
	var more_less_chosen = var_to_str(more_less_add)
	words_array.shuffle()
	chosen = words_array.front()
	words_array.pop_front()
	match more_less_chosen:
		"0":
			pass
		"1":
			chosen = "more " + chosen
		"2":
			chosen = "less " + chosen
		_:
			print("broken")
	return chosen
	
func _prophecy_or():
	print("or")
	var or_and = [
		" or ",
		" and "
	]
	var max_loops = 5
	var loops = randi_range(2, max_loops)
	var or_sentence:String
	var current_word:String
	for i in loops :
		var random_index = randi() % or_and.size()
		words_array.shuffle()
		current_word = words_array.front()
		words_array.pop_front()
		if i == 0 :
			or_sentence = current_word + or_and[random_index]
		elif i == loops - 1 :
			or_sentence = or_sentence + current_word
		else: 
			or_sentence = or_sentence + current_word + or_and[random_index]
		
#	words_selected.append(words_array.front())	
#	for y in words_selected :
#		if y == words_selected.back():
#			or_sentence = y + or_sentence
#		else:
#			or_sentence = y + " or " + or_sentence
	return or_sentence
	

func _prophecy_sentence():
	print("sentence")

#---------- stage 2

#debug
#func _on_button_pressed():
#	DisplayServer.window_set_size(Vector2i(512,512))


func _on_button_pressed():
	$prophecy_stages.current_tab = 2
	_select_prophecy()
	
