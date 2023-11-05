extends YSort


export(PackedScene) var enemy_scene
export(PackedScene) var extra_scene

var score = -1
var inter_score = -1
var speed_range = [-1, -1]
var mob_num = -1
var enemy_offsets = [-1]
var location_index = -1
var enemy_sound = 0
var volume_c = 0


func _ready():
	randomize()


func _process(delta):
	var enemies = []
	var static_enemies = []
	for x in get_children():
		if "Enemy" in x.name and not "Timer" in x.name and not "Static" in x.name:
			enemies.append(x)
		if "StaticEnemy" in x.name:
			static_enemies.append(x)
	
	for x in enemies:
		if x.dropped_extra == false and x.position.x >= 20 and x.position.x <= 460:
			var rn = int(rand_range(1, 150))
			if rn == 1:
				var extra = extra_scene.instance()
				extra.position = x.position
				extra.timeout_val = randi() % 5 + 4
				extra.set_addons(randi() % 4 + 1, randi() % 20 + 1)
				x.dropped_extra = true
				add_child(extra)
	
	if not $HUD.mute_music and not $HUD.mute_sfx:
		if volume_c < 0:
			volume_c += 0.5
		if $ExtraSound.playing or $ExtraPlusSound.playing:
			$BgMusicMain.volume_db = 0
			volume_c = 0
		else:
			$BgMusicMain.volume_db = volume_c
		if $NewMobSound.playing:
			$BgMusicMain.volume_db = -5
			volume_c = -5
		else:
			$BgMusicMain.volume_db = volume_c


func new_game():
	score = 0
	inter_score = 0
	speed_range = [100, 150]
	mob_num = 1
	enemy_offsets = []
	location_index = randi() % 2
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("extras", "queue_free")
	$Player.position = Vector2(240, 360)
	$Player.hit_emitted = false
	$Player.show()
	$HUD.show_special_message("GET READY...")
	$HUD/ScoreLabel.text = str(score)
	$HUD/ScoreLabel.show()
	$LostSound.stop()
	$WonSound.stop()
	$BgMusicIntro.play()
	$StartGameTimer.start()
	$EnemyTimer.wait_time = 1.85
	$EnemyTimer.start()
	$ScoreTimer.wait_time = 1.85
	$ScoreTimer.start()


func spawn_mob(location_range, enemy_range, cust_position=null):
	var enemy = enemy_scene.instance()
	var _speed_range = speed_range.duplicate(true)
	var enemy_location = -1
	var enemy_num = int(rand_range(enemy_range[0], enemy_range[1] + 1))
	var static_enemy = null
	
	match int(rand_range(location_range[0], location_range[1] + 1)):
		1:
			enemy_location = get_node("VPath/EnemyLocation")
		2:
			enemy_location = get_node("VPath2/EnemyLocation")
			_speed_range[0] *= -1
			_speed_range[1] *= -1
			enemy.reverse = true
	
	enemy.set_enemy(enemy_num)
	if enemy_num == 4:
			static_enemy = enemy_scene.instance()
			static_enemy.name = "StaticEnemy"
			static_enemy.static_enemy_timeout_val = randi() % 8 + 1
			static_enemy.static_enemy_drop_pos = rand_range(180, 300)
			static_enemy.set_enemy(5)
	
	var rn = -1
	var loop = true
	while loop:
		rn = int(rand_range(80, 720))
		loop = false
		for x in enemy_offsets.slice(-4, len(enemy_offsets) - 1):
			if rn >= (x - 80) and rn <= (x + 80):
				loop = true
				break
	enemy_offsets.append(rn)
	
	if cust_position:
		enemy_location.position = cust_position
		enemy.set_position(cust_position)
	else:
		enemy_location.offset = rn
		enemy.set_position(enemy_location.position)
	
	var velocity = Vector2(rand_range(_speed_range[0], _speed_range[1]), 0)
	enemy.linear_velocity = velocity
	
	add_child(enemy)
	
	if static_enemy:
		if enemy.reverse:
			static_enemy.reverse = true
		static_enemy.set_position(enemy_location.position)
		static_enemy.linear_velocity = velocity
		add_child(static_enemy)


func save_game():
	var p = "user://best_score.txt"
	var file_r = File.new()
	var file_w = File.new()
	
	file_r.open(p, File.READ)
	var best_score = int(file_r.get_as_text())
	file_r.close()
	
	if score > best_score:
		file_w.open(p, File.WRITE)
		file_w.store_string(str(score))
		file_w.close()
		best_score = score
	
	return best_score


func _on_EnemyTimer_timeout():
	var location_ranges = [[1, 1], [2, 2]]
	var location_range = location_ranges[location_index]
	var enemy_range = [1, 1]
	var enemy_interval = 2
	var speed_interval = 16
	var mob_add = 1
	
	if score >= 403 and score < 806:
		enemy_range = [1, 2]
		speed_interval = 12
		if enemy_sound == 0:
			enemy_range = [2, 2]
			if inter_score % enemy_interval == 0:
				$HUD.show_special_message("NEW ENEMY!")
				$NewMobSound.play()
				enemy_sound = 1
	if score >= 806 and score < 1007:
		enemy_range = [1, 3]
		speed_interval = 8
		if enemy_sound == 1:
			enemy_range = [3, 3]
			if inter_score % enemy_interval == 0:
				$HUD.show_special_message("NEW ENEMY!")
				$NewMobSound.play()
				enemy_sound = 2
	if score >= 1007 and score < 1209:
		enemy_range = [1, 4]
		speed_interval = 8
		if enemy_sound == 2:
			enemy_range = [4, 4]
			if inter_score % enemy_interval == 0:
				$HUD.show_special_message("NEW ENEMY!")
				$NewMobSound.play()
				enemy_sound = 3
	if score >= 1209 and score < 1410:
		enemy_range = [1, 4]
		speed_interval = 4
		mob_add = 2
		if enemy_sound == 3:
			if inter_score % 31 <= 1 and inter_score % enemy_interval == 0:
				$HUD.show_special_message("SPAWNING MORE MOBS!")
				$NewMobSound.play()
				enemy_sound = 4
	if score >= 1410:
		enemy_range = [1, 4]
		speed_interval = 4
		mob_add = 2
		enemy_interval = 1
		if enemy_sound == 4:
			if inter_score % enemy_interval == 0:
				$HUD.show_special_message("FASTER SPAWNING TIME!")
				$NewMobSound.play()
				enemy_sound = 0
	
	if inter_score % speed_interval == 0 and inter_score != 0:
		speed_range[0] += 1
		speed_range[1] += 2
	if inter_score % 31 == 0 and inter_score != 0:
		mob_num += mob_add
	
	if inter_score >= 1:
		location_range = [1, 2]
	
	
	if inter_score % enemy_interval == 0:
		for _i in range(mob_num):
			spawn_mob(location_range, enemy_range)
	
	inter_score += 1


func stop_game(won):
	if won:
		$WonSound.play()
	if not won:
		$NewMobSound.stop()
		$LostSound.play()
	$BgMusicMain.stop()
	
	$EnemyTimer.stop()
	$ScoreTimer.stop()
	
	var best_score = save_game()
	$HUD/ScoreLabel.hide()
	$Player.hide()
	
	var message = null
	if won:
		message = "YOU WON!"
		$HUD/ImageNode/StartButton.text = "Repeat?"
		$Player.hit_emitted = true
	else:
		message = "GAME OVER!"
		$HUD/ImageNode/StartButton.text = "Try again?"
	
	$HUD/ImageNode/Message.bbcode_text = """[center][color=#7b5727]---––- ~*~ -––---[/color]
[b]{message}[/b]
[color=#7b5727]---––- ~*~ -––---[/color]
[b][i]Current score:[/i][/b] {curr_score}
[b][i]Best score:[/i][/b] {best_score}[/center]""".format({"message": message, "curr_score": str(score), "best_score": str(best_score)})
	
	$HUD.drop_image()


func _on_ScoreTimer_timeout():
	$HUD/ScoreLabel.text = str(score)
	if score >= 1612:
		stop_game(true)
	
	score += 1


func _on_Player_hit():
	stop_game(false)


func _on_Player_pick(score_addon, bonus_addon):
	score += score_addon
	$HUD/ScoreLabel.text = str(score)
	$HUD.highlight_score()
	$HUD.show_addon(score_addon, $Player.position)
	if bonus_addon == 1 and mob_num > 1:
		mob_num -= 1
		$HUD.show_special_message("MINUS ONE MOB!")
		$ExtraPlusSound.play()
	else:
		$ExtraSound.play()


func _on_HUD_toggle_sfx(play):
	if play:
		get_tree().call_group("audio_sfx", "set_volume_db", 0)
	else:
		get_tree().call_group("audio_sfx", "set_volume_db", -80)


func _on_StartGameTimer_timeout():
	$EnemyTimer.wait_time = 1
	$ScoreTimer.wait_time = 1
	score = 1
#	$HUD.show_special_message("GO!")
	$BgMusicIntro.stop()
	$BgMusicMain.play()
