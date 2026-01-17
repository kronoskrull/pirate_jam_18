extends CharacterBody2D

@onready var sprite: Sprite2D = $flippable_sprite




var left: bool
var right: bool
var up: bool
var down: bool
var speed: float = 5.0

var moving: bool
var vector: Vector2
var cur_special_type: int

func _physics_process(delta: float) -> void:
	get_input_velocity()
	position.x += vector.x * speed
	position.y += vector.y * speed


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
		vector.y = 0.5
		cur_special_type = 4
	elif up:
		moving = true
		vector.y = -0.5
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
		moving = true
		vector.x = 1
		cur_special_type = 1
	
	return vector
