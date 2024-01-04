extends Control

@export var nodes_paths:Array[NodePath]
@export var knock_speed:float
@export var prophechy_speed:int

var knock_knock = 0
var current_stage = 0

#sounds
var knock_sound = preload("res://assets/sfx/knock_knock.wav")
var prophecy_calculating = preload("res://assets/sfx/laugh_01.wav")
var prophecy_finished = preload("res://assets/sfx/1054.wav")
var snap = preload("res://assets/sfx/snap.wav")
var steps = preload("res://assets/sfx/steps.ogg")
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
var preword_array = []


func _ready():
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(20,20))
	Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_POINTING_HAND, Vector2(24,24))
#	$AnimationPlayer.play("intro_fade-in")
	
	#load all words lists into arrays
	_load_file_list("res://assets/texts/reactions.txt", reactions_array)
	_load_file_list("res://assets/texts/words.txt", words_array)
	_load_file_list("res://assets/texts/pre_words.txt", preword_array)
	

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

# intro -----------
	
func _on_start_button_pressed():
	_play_sfx(snap)
	$prophecy_stages.current_tab = 1
	if not get_node(nodes_paths[6]).is_stopped():
		get_node(nodes_paths[6]).stop()
	
func _on_start_button_mouse_entered():
	print("test")
	get_node(nodes_paths[6]).start()

func _on_start_button_mouse_exited():
	get_node(nodes_paths[6]).stop()
	$prophecy_stages/intro/TextureRect.visible = true

func _on_flash_timer_timeout():
	$prophecy_stages/intro/TextureRect.visible = !$prophecy_stages/intro/TextureRect.visible

# ----------- intro

#doorstep ----------

func _on_knock_button_pressed():
	var button = get_node(nodes_paths[4])
	if knock_knock == 1:
		knock_knock = 0
		$prophecy_stages.current_tab = 2
		_play_sfx(steps)
		get_node(nodes_paths[4]).text = "enter"
		
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
		if knock_knock == 1:
			get_node(nodes_paths[4]).text = "enter"
#			knock_bar.self_modulate = Color(1,1,1,0)

func _print_reaction():
	reactions_array.shuffle()
	get_node(nodes_paths[5]).text = reactions_array.front()
#	reactions_array.pop_front()

#---------- doorstep

# room ---------
func _on_ask_button_pressed():
	$prophecy_stages.current_tab = 3
	get_node(nodes_paths[1]).start()
	_play_sfx(snap)
# -------- room

#reading ----------

func _on_prophecy_timer_timeout():
	random_pics.shuffle()
	var prophecy_bar = get_node(nodes_paths[0])
	var pic_selected = random_pics.front()
	if prophecy_bar.value >= 100:
		prophecy_bar.value = 0
		get_node(nodes_paths[1]).stop()
		_play_sfx(prophecy_finished)
		$prophecy_stages.current_tab = 4
		_select_prophecy()
	else:
		prophecy_bar.value += prophechy_speed
	$prophecy_stages/reading/TextureRect.texture = pic_selected

#---------- reading


#stage 2 ----------

func _select_prophecy():
	var random = randi_range(1,2)
	var method = var_to_str(random)
	if words_array.size() <= 5:
		print("repopulating")
		_load_file_list("res://assets/texts/words.txt", words_array)
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
	var chosen_word
	var chosen_pre
	var final_word
	preword_array.shuffle()
	chosen_pre = preword_array.front()
	words_array.shuffle()
	chosen_word = words_array.front()
	words_array.pop_front()
	final_word = chosen_pre + " " + chosen_word
	return final_word
	
func _prophecy_or():
	print("or")
	var or_and = [
		" or ",
		" and ",
		" with "
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

func _on_restart_button_pressed():
	$prophecy_stages.current_tab = 0


#---------- stage 2

#debug
#func _on_button_pressed():
#	DisplayServer.window_set_size(Vector2i(512,512))
#var more_less_add = randi_range(0,2)
#	var more_less_chosen = var_to_str(more_less_add)
#	words_array.shuffle()
#	chosen = words_array.front()
#	words_array.pop_front()
#	match more_less_chosen:
#		"0":
#			pass
#		"1":
#			chosen = "more " + chosen
#		"2":
#			chosen = "less " + chosen
#		_:
#			print("broken")


func _on_button_pressed():
	_play_sfx(snap)
	$prophecy_stages.current_tab = 4
	if words_array.size() <= 5:
		print("repopulating")
		_load_file_list("res://assets/texts/words.txt", words_array)
	_select_prophecy()
	





func _on_quit_button_pressed():
	get_tree().quit()
