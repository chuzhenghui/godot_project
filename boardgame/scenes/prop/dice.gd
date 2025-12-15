extends Node2D
class_name Dice

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var num :int = 0


func _ready() -> void:
	
	Main.execute_dice.connect(_on_execute_dice)
		


func _on_execute_dice(num: int) -> void:
	
	print(num)
	print(animated_sprite_2d)
	animated_sprite_2d.play("idle_"+str(num))
	
