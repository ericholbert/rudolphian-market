extends RigidBody2D


var score_addon = -1
var bonus_addon = -1
var timeout_val = -1
var timeout_counter = 0


func set_addons(n, n2):
	var texture = null
	var collision = null
	match(n):
		1:
			score_addon = 4
			texture = preload("res://assets/graphical/crystal.png")
			collision = preload("res://assets/graphical/CrystalCollision.tscn")
		2:
			score_addon = 8
			texture = preload("res://assets/graphical/globe.png")
			collision = preload("res://assets/graphical/GlobeCollision.tscn")
		3:
			score_addon = 12
			texture = preload("res://assets/graphical/statue.png")
			collision = preload("res://assets/graphical/StatueCollision.tscn")
		4:
			score_addon = 16
			texture = preload("res://assets/graphical/painting.png")
			collision = preload("res://assets/graphical/PaintingCollision.tscn")
	if n2 == 1:
		score_addon = 4
		bonus_addon = 1
		texture = preload("res://assets/graphical/crystal2.png")
		collision = preload("res://assets/graphical/CrystalCollision.tscn")
	$Sprite.texture = texture
	var collision_child = collision.instance()
	collision_child.position.y -= 20
	add_child(collision_child)


func _on_Timer_timeout():
	timeout_counter += 1
	if timeout_counter == timeout_val:
		queue_free()
