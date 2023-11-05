extends CanvasLayer


export (PackedScene) var addon_scene

signal start_game
signal toggle_sfx(play)
signal toggle_music(play)
var move_plus = true
var drop_image = false
var play_drop = false
var play_drop_c = 0
var special_messages = []
var mute_sfx = false
var mute_music = false


func _ready():
	$ImageNode.hide()
	$ImageBackground.hide()
	
	var p = "user://audio_setting.txt"
	var file_r = File.new()
	if not file_r.file_exists(p):
		return
	file_r.open(p, File.READ)
	var audio_setting = file_r.get_as_text(true).split(" ")
	if audio_setting[0] == "true":
		$CheckBox.pressed = true
		mute_sfx = false
	else:
		$CheckBox.pressed = false
		mute_sfx = true
	if audio_setting[1] == "true":
		$CheckBox2.pressed = true
		mute_music = false
	else:
		$CheckBox2.pressed = false
		mute_music = true


func _process(delta):
	if special_messages:
		if not is_instance_valid(special_messages[0]):
			special_messages.remove(0)
			return
		if not(special_messages[0] in get_children()):
			add_child(special_messages[0])
	
	if drop_image:
		var position_add = 900 * delta
		var position_add2 = 400 * delta
		$ImageNode.position.y = clamp($ImageNode.position.y, -1000, 320)
		
		if $ImageNode/Message.modulate.a >= 1:
			drop_image = false
			return
		
		if $ImageNode.position.y == 320:
			play_drop = true
		
		if play_drop:
			$ImageNode.position.y = clamp($ImageNode.position.y, 290, 320)
			if $ImageNode.position.y == 320:
				$DropAudio.play()
			if $ImageNode.position.y == 290 or $ImageNode.position.y == 320:
				play_drop_c += 1
			if play_drop_c % 2 == 1:
				$ImageNode.position.y -= position_add2
			else:
				$ImageNode.position.y += position_add2
			if play_drop_c == 5:
				play_drop = false
				$Timer.start()
		
		if not play_drop and play_drop_c == 0:
			$ImageNode.position.y += position_add
		
		if play_drop_c == 5:
			$ImageNode/Message.modulate.a += 0.05
			$ImageNode/StartButton.modulate.a += 0.05
			if not $ImageBackground.modulate.a >= 0.4:
				$ImageBackground.modulate.a += 0.05


func _on_StartButton_pressed():
	$ImageNode.hide()
	$ImageBackground.hide()
	$CheckBox.hide()
	$CheckBox2.hide()
	$DropAudio.volume_db = -80
	emit_signal("start_game")


func _on_Timer_timeout():
	var move_pxs = -1
	if move_plus:
		move_plus = false
		move_pxs = 2
	else:
		move_plus = true
		move_pxs = -2
	
	$ImageNode/TextureRect.rect_position.x += move_pxs
	$ImageNode/ColorRect.rect_position.x += move_pxs
	$ImageNode/TextureRect.rect_position.y += move_pxs
	$ImageNode/ColorRect.rect_position.y += move_pxs
	

func drop_image():
	$ImageNode/Message.modulate.a = 0
	$ImageNode/StartButton.modulate.a = 0
	$ImageNode.position.y = -220
	$ImageNode.show()
	
	$ImageBackground.modulate.a = 0
	$ImageBackground.show()
	
	$CheckBox.show()
	$CheckBox2.show()
	
	$Timer.stop()
	
	if not mute_sfx:
		$DropAudio.volume_db = 0
	
	drop_image = true
	play_drop = false
	play_drop_c = 0


func highlight_score():
	$ScoreLabel.get_font("font").size = 36
	$HighlightScoreTimer.start()


func show_addon(text, position):
	var addon = addon_scene.instance()
	addon.set(text, position)
	add_child(addon)
	move_child(addon, 0)


func show_special_message(text):
	var special_message = addon_scene.instance()
	special_message.set_message(text)
	special_message.name = "SpecialMessageLabel"
	special_messages.append(special_message)


func set_audio():
	var p = "user://audio_setting.txt"
	var file_w = File.new()
	file_w.open(p, File.WRITE)
	
	var audio_setting = ""
	if mute_sfx:
		audio_setting += "false"
	else:
		audio_setting += "true"
	audio_setting += " "
	if mute_music:
		audio_setting += "false"
	else:
		audio_setting += "true"
	
	file_w.store_string(audio_setting)


func _on_StartGameTimer_timeout():
	drop_image()


func _on_HighlightScoreTimer_timeout():
	$ScoreLabel.get_font("font").size = 32


func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		get_tree().call_group("audio_sfx", "set_volume_db", 0)
		emit_signal("toggle_sfx", true)
		mute_sfx = false
	else:
		get_tree().call_group("audio_sfx", "set_volume_db", -80)
		emit_signal("toggle_sfx", false)
		mute_sfx = true
	set_audio()


func _on_CheckBox2_toggled(button_pressed):
	if button_pressed:
		get_tree().call_group("audio_music", "set_volume_db", 0)
		emit_signal("toggle_music", true)
		mute_music = false
	else:
		get_tree().call_group("audio_music", "set_volume_db", -80)
		emit_signal("toggle_music", false)
		mute_music = true
	set_audio()
