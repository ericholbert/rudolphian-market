extends RigidBody2D

var static_enemy_timeout_val = -1
var static_enemy_counter = 0
var static_enemy_schedule = false
var static_enemy_animation = false
var static_enemy_drop_pos = -1
var dropped_extra = false
var reverse = false


func _process(delta):
	if $AnimatedSprite.animation == "enemy4b_walk":
		var is_correct_pos = position.x >= static_enemy_drop_pos - 10 and position.x <= static_enemy_drop_pos + 10
		if is_correct_pos and static_enemy_animation == false:
			static_enemy_schedule = true


func _ready():
	if reverse:
		$AnimatedSprite.scale = Vector2(-2, 2)
		$CollisionPolygon2Da.scale = Vector2(-1, 1)
		$CollisionPolygon2Db.scale = Vector2(-1, 1)


func set_enemy(num):
	var collision_a = null
	var collision_b = null
	match num:
		1:
			$AnimatedSprite.animation = "enemy_walk"
			collision_a = preload("res://assets/graphical/EnemyCollision_a.tscn")
			collision_b = preload("res://assets/graphical/EnemyCollision_b.tscn")
		2:
			$AnimatedSprite.animation = "enemy2_walk"
			$AnimatedSprite.position.y = -27
			collision_a = preload("res://assets/graphical/Enemy2Collision_a.tscn")
			collision_b = preload("res://assets/graphical/Enemy2Collision_b.tscn")
		3:
			$AnimatedSprite.animation = "enemy3_walk"
			collision_a = preload("res://assets/graphical/Enemy3Collision_a.tscn")
			collision_b = preload("res://assets/graphical/Enemy3Collision_b.tscn")
		4:
			$AnimatedSprite.animation = "enemy4_walk"
			collision_a = preload("res://assets/graphical/Enemy4Collision_a.tscn")
			collision_b = preload("res://assets/graphical/Enemy4Collision_b.tscn")
		5:
			$AnimatedSprite.animation = "enemy4b_walk"
			collision_a = preload("res://assets/graphical/Enemy4bCollision_a.tscn")
			collision_b = preload("res://assets/graphical/Enemy4bCollision_b.tscn")
	var collision_a_node = collision_a.instance()
	var collision_b_node = collision_b.instance()
	if reverse:
		collision_a_node.scale = Vector2(-1, 1)
		collision_b_node.scale = Vector2(-1, 1)
	collision_a_node.name = "CollisionPolygon2Da"
	collision_b_node.name = "CollisionPolygon2Db"
	$CollisionPolygon2Da.replace_by(collision_a_node)
	$CollisionPolygon2Db.replace_by(collision_b_node)


func set_position(pos):
	var position_alt = -1
	position = pos
	match $AnimatedSprite.animation:
		"enemy_walk":
			position_alt = 29
		"enemy2_walk":
			position_alt = 42
		"enemy3_walk":
			position_alt = 42
		"enemy4_walk":
			position_alt = 29
		"enemy4b_walk":
			position_alt = 29
	if reverse:
		position.x += position_alt
	else:
		position.x -= position_alt


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_StaticEnemyTimer_timeout():
	static_enemy_counter += 1
	if static_enemy_counter == static_enemy_timeout_val:
		queue_free()


func _on_AnimatedSprite_frame_changed():
	if static_enemy_schedule and $AnimatedSprite.frame == 1:
		$AnimatedSprite.animation = "enemy4b_drop"
		$CollisionPolygon2Db.queue_free()
		static_enemy_schedule = false
		static_enemy_animation = true
	
	if static_enemy_animation:
		var collision = null
		match $AnimatedSprite.frame:
			0:
				collision = preload("res://assets/graphical/Enemy4bCollision_ac.tscn")
			1:
				collision = preload("res://assets/graphical/Enemy4bCollision_cd.tscn")
			2:
				collision = preload("res://assets/graphical/Enemy4bCollision_de.tscn")
			3:
				collision = preload("res://assets/graphical/Enemy4bCollision_ef.tscn")
				if $StaticEnemyTimer.is_stopped():
					linear_velocity = Vector2(0, 0)
					$StaticEnemyTimer.start()
		var collision_node = collision.instance()
		collision_node.name = "CollisionPolygon2Da"
		collision_node.disabled = false
		if reverse:
			collision_node.scale = Vector2(-1, 1)
		$CollisionPolygon2Da.replace_by(collision_node)
		return
	
	if $AnimatedSprite.frame == 0:
		$CollisionPolygon2Da.disabled = false
		$CollisionPolygon2Da.visible = true
		
		$CollisionPolygon2Db.disabled = true
		$CollisionPolygon2Db.visible = false
	if $AnimatedSprite.frame == 1:
		$CollisionPolygon2Da.disabled = true
		$CollisionPolygon2Da.visible = false
		
		$CollisionPolygon2Db.disabled = false
		$CollisionPolygon2Db.visible = true
