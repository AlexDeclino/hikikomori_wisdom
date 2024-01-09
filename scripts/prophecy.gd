extends Control

@export var nodes_paths:Dictionary
@export var prophechy_speed:int

var knock_knock = 0
var current_stage = 0

#sounds
var knock_sound = preload("res://assets/sfx/knock_knock.wav")
var prophecy_calculating = preload("res://assets/sfx/laugh_01.wav")
var prophecy_finished = preload("res://assets/sfx/1054.wav")
var snap = preload("res://assets/sfx/snap.wav")
var steps = preload("res://assets/sfx/steps.ogg")
var hmmmm = preload("res://assets/sfx/SE_00_27.wav")
var applause = preload("res://assets/sfx/SE_00_38.wav")
var calculating = preload("res://assets/sfx/SE_00_13.wav")
#cursors
var hand_cursor = preload("res://assets/cursors/hand_knock.png")
var arrow_cursor = preload("res://assets/cursors/hand_normal.png")

var random_pics = [
		preload("res://assets/hikiko/h_running_i.png"),
		preload("res://assets/hikiko/h_running.png")
	]

#lists
var words_array = []
var preword_array = []
var dialogues_array = []
var questions_array = []

#stats var
var money = 0
var rest = 300
var daytime = 0

#hikikomori labels
@onready var labels:Array = $prophecy_stages/intro/HFlowContainer.get_children()
var is_question = false

func _ready():
	get_node(nodes_paths["dialogue_label"]).text = "press START to START the prophecy. Your data is being collected."
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(20,20))
	Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_POINTING_HAND, Vector2(24,24))

	
	#load all words lists into arrays
	_load_file_list("res://assets/texts/words.txt", words_array)
	_load_file_list("res://assets/texts/pre_words.txt", preword_array)
	_load_file_list("res://assets/texts/dialogues.txt", dialogues_array)
	_load_file_list("res://assets/texts/questions.txt", questions_array)
	

	#apply settings for cursor and focus to all buttons
	var buttons = get_tree().get_nodes_in_group("buttons")
	for i in buttons:
		i.focus_mode = FOCUS_NONE
		i.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		
	_turn_off_labels()

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

func _on_quit_button_pressed():
	_play_sfx(snap)
	get_tree().quit()
	
func _on_question_button_pressed():
	_play_sfx(hmmmm)
	var current_tab = $prophecy_stages.current_tab
	var current_tab_match = var_to_str(current_tab)
	var dialogue = get_node(nodes_paths["dialogue_label"])
	match current_tab_match:
		"0":
			dialogue.text = "Do I really want this?"
		_:
			dialogue.text = "none"


func _change_dialogue(text:String):
	get_node(nodes_paths["dialogue_label"]).text = text

# intro -----------

	
func _on_start_button_pressed():
	_play_sfx(snap)
	$prophecy_stages.current_tab += 1
	_change_dialogue("b-tier hikikomori unlocked. KNOCK to begin the prophecy.")
	#this stops flash timer just in case
	if not get_node(nodes_paths["flash_timer"]).is_stopped():
		get_node(nodes_paths["flash_timer"]).stop()
	
func _on_start_button_mouse_entered():
	get_node(nodes_paths["flash_timer"]).start()
	is_question = true
	for i in labels:
		if i == labels[10]:
			i.self_modulate.a = 1
		else:
			i.self_modulate.a = 0

func _on_start_button_mouse_exited():
	_turn_off_labels()
	is_question = false

func _turn_off_labels():
	for i in labels:
		if i == labels[10]:
			i.self_modulate.a = 1
		else:
			i.self_modulate.a = 0
			i.text = "HIKIKOMORI \n WISDOM"

func _on_flash_timer_timeout():
	var rand_index = randi_range(0,20)
	if is_question == true and rand_index != 10:
		labels[rand_index].text = questions_array[randi() % questions_array.size()]
	if labels[rand_index].self_modulate.a == 1:
		labels[rand_index].self_modulate.a = 0
	else:
		labels[rand_index].self_modulate.a = 1
		
	if labels[10].self_modulate.a == 0:
		labels[10].self_modulate.a = 1
	else:
		labels[10].self_modulate.a = 0
	
# ----------- intro

#doorstep ----------

func _on_knock_button_pressed():
	var button = get_node(nodes_paths["knock_button"])
	if knock_knock == 1:
		knock_knock = 0
		$prophecy_stages.current_tab = 3
		button.text = "knock"
		_change_dialogue("your prophecy will be ready in a moment")
		get_node(nodes_paths["prophecy_timer"]).start()
		_play_sfx(snap)
#	elif knock_knock == 0:
#		_change_dialogue("no answer")
#		button.disabled = true
#		$AnimationPlayer.play("knock")
#		await $AnimationPlayer.animation_finished
#		button.disabled = false
#		knock_knock += 1
	else:
		button.disabled = true
		$AnimationPlayer.play("door_opening")
		await $AnimationPlayer.animation_finished
		_play_sfx(hmmmm)
		button.disabled = false
		knock_knock += 1
		button.text = "how do I achieve peak happiness?"

#---------- doorstep

# room ---------
func _on_ask_button_pressed():
	$prophecy_stages.current_tab = 3
	get_node(nodes_paths["prophecy_timer"]).start()
	get_node(nodes_paths["receive_button"]).text = "........."
	_play_sfx(snap)
# -------- room

#reading ----------

func _on_prophecy_timer_timeout():
	_play_sfx(calculating)
	var prophecy_bar = get_node(nodes_paths["prophecy_bar"])
	if prophecy_bar.value >= 100:
		prophecy_bar.value = 0
		get_node(nodes_paths["prophecy_timer"]).stop()
		_play_sfx(calculating)
		get_node(nodes_paths["receive_button"]).disabled = false
		get_node(nodes_paths["receive_button"]).text = "I'm ready"
		get_node(nodes_paths["dialogue_label"]).text = "Please click the button above to receive your prophecy. Every sale is final-ish."
	else:
		prophecy_bar.value += prophechy_speed
	$prophecy_stages/reading/TextureRect2.visible = !$prophecy_stages/reading/TextureRect2.visible


func _on_receive_button_pressed():
	_play_sfx(applause)
	$prophecy_stages.current_tab = 4
	_select_prophecy()
	get_node(nodes_paths["receive_button"]).disabled = true
	get_node(nodes_paths["dialogue_label"]).text = "Your prophecy is served. Consider leaving a 5 stars review."
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
	_change_dialogue("press START to connect to one of our available hikikomori prophets.")
	$prophecy_stages.current_tab = 0
	$prophecy_stages/doorstep/door_rect.texture = preload("res://assets/hikiko/door0.png")

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
	



