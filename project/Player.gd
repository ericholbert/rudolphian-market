extends Area2D


var speed = 200
var screen_size
var is_first_frame = false
var hit_emitted = false
var loose_game = true
signal hit
signal pick(score_addon, bonus_addon, extra_position)


func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 80, screen_size.y)
	
	var collision_a_name = null
	var collision_b_name = null
	
	if velocity == Vector2.ZERO:
		$AnimatedSprite.animation = "rest"
		is_first_frame = true
		collision_a_name = "PlayerCollision_ac"
		collision_b_name = "PlayerCollision_b"
	elif velocity.x != 0:
		$AnimatedSprite.animation = "walk_x"
		if is_first_frame:
			$AnimatedSprite.frame = 1
			is_first_frame = false
		$AnimatedSprite.flip_h = velocity.x < 0
		collision_a_name = "PlayerCollision_ac"
		collision_b_name = "PlayerCollision_d"
	elif velocity.y < 0:
		$AnimatedSprite.animation = "walk_up"
		collision_a_name = "PlayerCollision_e"
		collision_b_name = "PlayerCollision_f"
	elif velocity.y > 0:
		$AnimatedSprite.animation = "walk_down"
		collision_a_name = "PlayerCollision_g"
		collision_b_name = "PlayerCollision_h"
		
	for x in get_tree().get_nodes_in_group("collisions"):
		if $AnimatedSprite.flip_h:
			if x.name == collision_a_name or x.name == collision_b_name:
				get_node(x.name).scale = Vector2(-1, 1)
		else:
			get_node(x.name).scale = Vector2(1, 1)
		if $AnimatedSprite.frame == 0:
			if x.name == collision_a_name:
				get_node(x.name).disabled = false
				get_node(x.name).visible = true
			else:
				get_node(x.name).disabled = true
				get_node(x.name).visible = false
		if $AnimatedSprite.frame == 1:
			if x.name == collision_b_name:
				get_node(x.name).disabled = false
				get_node(x.name).visible = true
			else:
				get_node(x.name).disabled = true
				get_node(x.name).visible = false


func _on_Player_body_entered(body):
	if "Enemy" in body.name and not loose_game:
		print("GAME OVER")
		return
	
	if "Enemy" in body.name and not hit_emitted:
		emit_signal("hit")
		hit_emitted = true
	if "Extra" in body.name:
		emit_signal("pick", body.score_addon, body.bonus_addon)
		body.queue_free()
