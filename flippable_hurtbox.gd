extends Area2D
class_name FlippableHurtbox

@export var flippable_sprite:FlippableSprite

signal received_damage(damage: int)

@export var parent: Node2D
@export var type: int = 0

func _ready() -> void:
	if flippable_sprite != null:
		for child in get_children():
			flippable_sprite.sprite_flipped.connect(child._on_sprite_flipped)
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: FlippableHitbox) -> void:
	if hitbox != null and !parent.flippable_shape.disabled:
		match hitbox.type:
			0:
				hitbox.connected()
				parent.take_hit(hitbox.damage)
			1:
				hitbox.grab_landed(parent)
				#parent.grabbed(hitbox.throw_pos_tracker)
