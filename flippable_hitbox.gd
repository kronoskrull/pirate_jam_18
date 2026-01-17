extends Area2D
class_name FlippableHitbox

@export var flippable_sprite:FlippableSprite

@export var damage: int = 0 : set = set_damage, get = get_damage
@export var knockback: Vector2 = Vector2(1000, 0) : set = set_knockback, get = get_knockback
@export var hitstun: int
@export var comboscalar: float = 1.0
@export var multihitbox: bool
@export var type: int
var drawrect: Rect2

func _ready() -> void:
	if flippable_sprite != null:
		for child in get_children():
			flippable_sprite.sprite_flipped.connect(child._on_sprite_flipped)
	

func set_damage(value: int):
	damage = value

func get_damage() -> int:
	return damage

func set_knockback(value: Vector2):
	knockback = value

func get_knockback() -> Vector2:
	return knockback
