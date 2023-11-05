extends Label


var free = false


func _ready():
	modulate.a = 0


func _process(delta):
	var modulation = 0.2
	if modulate.a < 1 and not free:
		modulate.a += modulation
	if free:
		modulate.a -= modulation
		if modulate.a <= 0:
			queue_free()


func set(addon_num, position):
	text = "+ " + str(addon_num)
	position.x = clamp(position.x, 20, 480 - (44 + 20))
	position.y = clamp(position.y, 20, 720 - (28 + 20))
	rect_position = position


func set_message(txt):
	$SpecialMessage.bbcode_text = "[center][wave amp=25.0 freq=5.0]" + txt + "[/wave][/center]"
	$SpecialMessage.show()
	$Timer.wait_time = 1


func _on_Timer_timeout():
	free = true
