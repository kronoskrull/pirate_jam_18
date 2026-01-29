extends Node2D
class_name FlippableNode2D

@export var flippable_sprite:FlippableSprite

@export var default_position: Vector2:
	set(new_position):
		default_position = new_position
		position = new_position 

var current_flip_value: bool

func _on_sprite_flipped(flip_value):
	if current_flip_value != flip_value:
		default_position.x *= -1
		current_flip_value = flip_value


func _on_flippable_sprite_sprite_flipped(flip_value: Variant) -> void:
	if current_flip_value != flip_value:
		default_position.x *= -1
		current_flip_value = flip_value
