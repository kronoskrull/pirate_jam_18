extends CharacterBody2D

@onready var sprite: Sprite2D = $flippable_sprite
@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart
@onready var enemy_grab_pos: Node2D = $enemy_grab_pos




var left: bool
var right: bool
var up: bool
var down: bool
var speed: float = 3.0

var moving: bool
@export var position_x_offset: float
@export var position_y_offset: float
@export var grab_pos_x_offset: float
@export var grab_pos_y_offset: float
var can_move: bool
@export var can_attack: bool
var hit_landed: bool = false
var in_command_grab: bool = false
var awaiting_for_command_grab: int = 0
var held_enemy
var spd_active: bool = false
var suplex_active: bool
var pummel_count: int = 0

var weapon: int = 0
var weapon_durability: int

var vector: Vector2
var offset_sprite: bool = false
var cur_special_type: int
var health = 5

func _ready() -> void:
	can_move = true
	weapon = 0
	can_attack = true
	weapon_durability = 100


func _physics_process(delta: float) -> void:
	vector = Vector2.ZERO
	
	if can_move:
		get_input_velocity()
		
		if vector.x != 0 or vector.y != 0:
			state_chart.send_event("moving")
		else:
			state_chart.send_event("idle")
	
	position.x += vector.x * speed * 0.95
	position.y += vector.y * speed * 0.75
	
	position.x = clampf(position.x, 20, 7245)
	position.y = clampf(position.y, 210 , 320)

func _process(delta: float) -> void:
	
	var new_pos: Vector2 = global_position
	var spriteint: int
	spriteint = 1 if !sprite.flipped else -1
	var x_offset = new_pos.x + position_x_offset * spriteint
	var y_offset = new_pos.y + position_y_offset
	
	if offset_sprite:
		sprite.global_position.x = x_offset
		sprite.global_position.y = y_offset
	# Useful for position altering during animations
	# Connect above w/ bottom of process for functionality
	
	
	if in_command_grab:
		
		if spd_active:
			enemy_grab_pos.global_position.x = x_offset + (50 * spriteint)
			enemy_grab_pos.global_position.y = y_offset
		
		if suplex_active:
			enemy_grab_pos.global_position.x = x_offset + (grab_pos_x_offset * spriteint)
			enemy_grab_pos.global_position.y = y_offset + grab_pos_y_offset
		
		if held_enemy:
			held_enemy.global_position = enemy_grab_pos.global_position
			
		
		
		if Input.is_action_just_pressed("pup"):
			state_chart.send_event("spd")
		if Input.is_action_just_pressed("pdown"):
			state_chart.send_event("ddt")
		if Input.is_action_just_pressed("pleft"):
			match sprite.flipped:
				false:
					state_chart.send_event("suplex")
				true:
					state_chart.send_event("fthrow")
		if Input.is_action_just_pressed("pright"):
			match sprite.flipped:
				false:
					state_chart.send_event("fthrow")
				true:
					state_chart.send_event("suplex")
	
	
	if Input.is_action_just_pressed("pattack") and (can_attack or in_command_grab):
		can_move = false
		can_attack = false
		
		if in_command_grab:
			var x = randi_range(0, 100)
			if pummel_count < 3:
				state_chart.send_event("pummel")
			else:
				pummel_count = 0
				state_chart.send_event("pummel_finish")
		else:
			match weapon:
				0: # Unarmed
					if anims.current_animation == "unarmed_attack_2" and hit_landed:
						state_chart.send_event("unarmed_3")
					elif anims.current_animation == "unarmed_attack_1" and hit_landed:
						state_chart.send_event("unarmed_2")
					else:
						state_chart.send_event("unarmed_1")
				1: # Camera Whip
					state_chart.send_event("cam_attack")
					weapon_durability -= 5
	
	if Input.is_action_just_pressed("pspecial") and can_attack:
		can_move = false
		can_attack = false
		
		match weapon:
			0:
				state_chart.send_event("unarmed_special")
		
	
	

func get_input_velocity() -> Vector2:
	left = Input.is_action_pressed("pleft")
	right = Input.is_action_pressed("pright")
	down = Input.is_action_pressed("pdown")
	up = Input.is_action_pressed("pup")
	
	cur_special_type = 0
	
	moving = false
	vector = Vector2(0, 0)
	
	if down and up:
		moving = false
		vector.y = 0
	elif down:
		moving = true
		vector.y = 1
		cur_special_type = 4
	elif up:
		moving = true
		vector.y = -1
		cur_special_type = 3
	
	if left and right:
		moving = false
		vector.x = 0
	elif left:
		sprite.flipped = true
		moving = true
		vector.x = -1
		cur_special_type = 1
	elif right:
		sprite.flipped = false
		sprite.sprite_flipped.emit(sprite.flipped)
		moving = true
		vector.x = 1
		cur_special_type = 1
	
	return vector

func command_grab_landed(enemy: Node2D) -> void: # CRITICAL: Unfinished! needs to be done for proper functionality
	held_enemy = enemy
	held_enemy.held = true
	in_command_grab = true
	state_chart.send_event("un_sp_succeed")

func pummel() -> void:
	held_enemy.take_hit(1)

func pummel_finish(dmg: int, launchtype: String) -> void:
	held_enemy.take_hit(dmg)
	in_command_grab = false
	var x: int = 1 if !sprite.flipped else -1
	match launchtype:
		"spd":
			held_enemy.release("launch", x)
		"suplex":
			held_enemy.release("launch", -x)
	held_enemy = null

func reset_enemy_grab_pos(type: int) -> void:
	match type:
		0:
			#var x: int = 1 if !sprite.flipped else -1
			#enemy_grab_pos.position.x *= x
			if sprite.flipped:
				sprite.flipped = true
				enemy_grab_pos.current_flip_value = false
				sprite.sprite_flipped.emit(sprite.flipped)
		1:
			var x: int = 1 if !sprite.flipped else -1
			enemy_grab_pos.position.x *= x

#region State Events

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"unarmed_attack_1":
			can_move = true
			can_attack = true
			hit_landed = false
			state_chart.send_event("idle")
		"unarmed_attack_2":
			can_move = true
			can_attack = true
			hit_landed = false
			state_chart.send_event("idle")
		"unarmed_attack_3":
			can_move = true
			can_attack = true
			hit_landed = false
			state_chart.send_event("idle")
		"unarmed_special":
			can_move = true
			can_attack = true
			hit_landed = false
			state_chart.send_event("idle")
		"pummel":
			state_chart.send_event("end_pummel")
			pummel_count += 1
		"pummel_finish":
			can_move = true
			can_attack = true
			hit_landed = false
			in_command_grab = false
			held_enemy = null
			pummel_count = 0
			state_chart.send_event("idle")
		"suplex":
			suplex_active = false
			can_move = true
			can_attack = true
			hit_landed = false
			in_command_grab = false
			held_enemy = null
			offset_sprite = false
			pummel_count = 0
			state_chart.send_event("idle")
		"spd":
			spd_active = false
			can_move = true
			can_attack = true
			hit_landed = false
			in_command_grab = false
			held_enemy = null
			offset_sprite = false
			pummel_count = 0
			state_chart.send_event("idle")
		"cam_attack":
			can_move = true
			can_attack = true
			hit_landed = false
			if weapon_durability <= 0:
				weapon = 0
			state_chart.send_event("idle")

func _on_walking_state_entered() -> void:
	anims.play("walk")


func _on_idle_state_entered() -> void:
	anims.play("idle")


func _on_unarmed_attack_1_state_entered() -> void:
	anims.play("unarmed_attack_1")


func _on_unarmed_attack_2_state_entered() -> void:
	anims.play("unarmed_attack_2")


func _on_unarmed_attack_3_state_entered() -> void:
	anims.play("unarmed_attack_3")


func _on_cam_attack_state_entered() -> void:
	anims.play("cam_attack")


func _on_unarmed_special_state_entered() -> void:
	anims.play("unarmed_special")


func _on_un_sp_succeed_state_entered() -> void:
	anims.play("un_sp_nexus")


func _on_pummel_state_entered() -> void:
	anims.play("pummel")


func _on_pummel_finish_state_entered() -> void:
	anims.play("pummel_finish")



func _on_spd_state_entered() -> void:
	spd_active = true
	offset_sprite = true
	anims.play("spd")


func _on_suplex_state_entered() -> void:
	suplex_active = true
	offset_sprite = true
	anims.play("suplex")
