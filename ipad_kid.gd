extends Node2D

@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var flippable_shape: FlippableShape = $hurtbox_component/flippable_shape
@onready var invulntimer: Timer = $invulntimer
@onready var player = get_tree().get_first_node_in_group("player")

var health: int = 10
var atkRange = 60
var atkCount = 10
var moveSpeed = 70
var vector: Vector2

var launched: bool
var launchspd: float
var face_dir: int
var ogpos: Vector2
@export var position_x_offset: float
@export var position_y_offset: float
var offset: bool

var queue_death: bool
var held: bool

func take_hit(dmg: int) -> void:
	if dmg >= 1:
		health -= dmg
		if health > 0:
			anims.stop()
			anims.play("hurt")
			#flippable_shape.disabled = true
			#invulntimer.start()
		else:
			if held:
				queue_death = true
				anims.stop()
				anims.play("hurt")
			else:
				anims.play("death")

func _physics_process(delta: float) -> void:
	var new_pos: Vector2 = global_position
	var x_offset = ogpos.x + position_x_offset * face_dir * -1
	#var x_offset = ogpos.x * face_dir
	var y_offset = ogpos.y + position_y_offset
	
	if offset:
		global_position.x = x_offset
		global_position.y = y_offset
	
	
	#Approach/Attack

	if (self.global_position.x - player.global_position.x) + (self.global_position.y - player.global_position.y) <= abs(atkRange):
		attack()

	if ((self.global_position.x - player.global_position.x > 0) && player.sprite.flipped == false) || ((self.global_position.x - player.global_position.x <= 0) && player.sprite.flipped == true):
		#play with ipad animation thing
		pass
	#Up/Down
	else:
		if self.global_position.y - player.global_position.y > 1:
			#move down
			global_position.y -= moveSpeed * delta
			pass
		elif self.global_position.y - player.global_position.y < -1:
			#move up
			global_position.y += moveSpeed * delta
			pass
		
		if self.global_position.x - player.global_position.x > atkRange:
			#move left
			global_position.x -= moveSpeed * delta
			pass
		elif self.global_position.x - player.global_position.x < -atkRange:
			#move right
			global_position.x += moveSpeed * delta
			pass


func release(type: String, dir: int) -> void:
	match type:
		"launch":
			if anims.current_animation == "death":
				queue_death = true
			anims.stop()
			anims.play("launch")
			ogpos = global_position
			face_dir = dir * -1
			offset = true
			launched = true

func _on_invulntimer_timeout() -> void:
	flippable_shape.disabled = false

func attack():
	#check atkcount for timer
	if atkCount > 0:
		atkCount -=1
		pass
	else:
		pass
	#do animation/hitbox manipulation or pass
	#deal damage
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"death":
			queue_free()
		"launch":
			global_position = Vector2(ogpos.x + position_x_offset * face_dir * -1, ogpos.y + position_y_offset)
			launched = false
			offset = false
			ogpos = Vector2.ZERO
			position_x_offset = 0
			position_y_offset = 0
			if queue_death:
				queue_death = false
				anims.play("death")
