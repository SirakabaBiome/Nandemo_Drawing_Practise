extends Node2D

@onready var draw_timer: Timer = %DrawTimer
@onready var count_down_timer: Timer = %CountDownTimer
@onready var cool_down_timer: Timer = %CoolDownTimer
@onready var status_label: Label = %StatusLabel
@onready var time_label: Label = %TimeLabel
@onready var time_label_num: Label = %TimeLabelNum
@onready var time_edit: TextEdit = %TimeEdit
@onready var _15s: Button = %"15s"
@onready var _30s: Button = %"30s"
@onready var _60s: Button = %"60s"
@onready var _90s: Button = %"90s"
@onready var _120s: Button = %"120s"
@onready var _180s: Button = %"180s"
@onready var start_button: Button = %StartButton
@onready var stop_button: Button = %StopButton
@onready var result_num: Label = %ResultNum
@onready var top_toggle: CheckButton = %TopToggle
@onready var image_rect: TextureRect = %ImageRect
@onready var file_dialog: FileDialog = %FileDialog
@onready var system_message_label: Label = %SystemMessageLabel

var dir : DirAccess

var time_count : int = 0
var is_draw := false

var image_file_absolute_path_list : Array = []
var drew_list : Array = []

var draw_count : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_time_set(60)
	file_dialog.show()

func _process(delta: float) -> void:
	pass

func draw_time_set(time:int) -> void:
	if draw_timer.is_stopped() and cool_down_timer.is_stopped():
		time_count = time
		draw_timer.wait_time = time
		time_edit.text = str(time)
		time_display_set(time)

func cooldown_time_set(time:int):
	time_count = time
	cool_down_timer.wait_time = time
	time_display_set(time) 

func time_display_set(time:int):
	time_label_num.text = str(time)

func _on_count_down_timer_timeout() -> void:
	if time_label_num.text == "ERROR!!":
		cool_down_timer.stop()
		draw_timer.stop()
		count_down_timer.stop()
		return
	if not draw_timer.is_stopped():
		time_count -= 1
		time_display_set(time_count)
	elif not cool_down_timer.is_stopped():
		time_count -= 1
		time_display_set(time_count)
	else:
		count_down_timer.stop()

func _on_start_button_pressed() -> void:
	image_change()
	if time_label_num.text == "ERROR!!":
		return
	var time :int= draw_timer.wait_time
	time_display_set(time)
	time_count = time
	draw_timer.start()
	count_down_timer.start()
	status_label.text = "描写時間中です"

func _on_draw_timer_timeout() -> void:
	if time_label_num.text == "ERROR!!":
		cool_down_timer.stop()
		draw_timer.stop()
		count_down_timer.stop()
		return
	await get_tree().create_timer(1).timeout
	var time :int= cool_down_timer.wait_time
	time_display_set(time)
	time_count = time
	cool_down_timer.start()
	count_down_timer.start()
	status_label.text = "休憩時間中です"

func _on_cool_down_timer_timeout() -> void:
	if time_label_num.text == "ERROR!!":
		cool_down_timer.stop()
		draw_timer.stop()
		count_down_timer.stop()
		return
	await get_tree().create_timer(1).timeout
	_on_start_button_pressed()

func _on_time_edit_text_changed() -> void:
	if time_edit.text.is_valid_float():
		system_message_hide()
		var time : int = int(time_edit.text)
		time_count = time
		draw_timer.wait_time = time
		time_display_set(time)
	else:
		system_message_show("半角数字だけ入れてください！")
		time_label_num.text = "ERROR!!"

func _on_time_edit_text_set() -> void:
	pass

func _on_stop_button_pressed() -> void:
	status_label.text = "休憩時間中です"
	cool_down_timer.stop()
	draw_timer.stop()
	count_down_timer.stop()

func image_change():
	if not image_file_absolute_path_list.is_empty():
		system_message_hide()
		randomize()
		var random_num : int = randi_range(0,image_file_absolute_path_list.size() - 1)
		var image_path = image_file_absolute_path_list.pop_at(random_num)
		drew_list.append(image_path)
		image_rect.texture = ImageTexture.create_from_image(Image.load_from_file(image_path))
		draw_count += 1
		result_num.text = str(draw_count)
	else:
		time_label_num.text = "ERROR!!"
		system_message_show("画像がありません！")
		print("error!")

func _on_file_dialog_dir_selected(dir_path: String) -> void:
	image_file_absolute_path_list = []
	var files := DirAccess.get_files_at(dir_path)
	var extension_list = ["jpeg","JPEG","jpg","JPG","png","PNG"]
	for filename in files:
		var is_ext_match := false
		for ext in extension_list:
			if filename.ends_with(ext):
				is_ext_match = true
		if is_ext_match:
			image_file_absolute_path_list.append(dir_path.path_join(filename))
	print(image_file_absolute_path_list)

func _on_directory_select_button_pressed() -> void:
	file_dialog.show()

func _on_check_button_pressed() -> void:
	var root : Window = get_node("/root")
	root.always_on_top = top_toggle.button_pressed

func system_message_show(txt:String) -> void:
	system_message_label.show()
	system_message_label.text = txt
	await get_tree().create_timer(5).timeout
	system_message_hide()

func system_message_hide():
	system_message_label.hide()
