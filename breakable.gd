extends Node2D


@export var health: int
@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var flippable_shape: FlippableShape = $hurtbox_component/flippable_shape
@onready var sprite: FlippableSprite = $FlippableSprite


@onready var ogpos = global_position
@export var position_x_offset: float
@export var position_y_offset: float
var face_dir: int = 1
var offset: bool

func _physics_process(_delta: float) -> void:
	#var x_offset = ogpos.x + position_x_offset * face_dir * -1
	var x_offset = ogpos.x + position_x_offset * face_dir
	var y_offset = ogpos.y + position_y_offset
	
	if offset:
		sprite.global_position.x = x_offset
		sprite.global_position.y = y_offset

func take_hit(dmg: int) -> void:
	if dmg >= 1:
		health -= dmg
		if health > 0:
			offset = true
			anims.stop()
			anims.play("damage")
			#flippable_shape.disabled = true
			#invulntimer.start()
		else:
			offset = true
			anims.stop()
			anims.play("break")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"damage":
			offset = false
		"break":
			queue_free()
