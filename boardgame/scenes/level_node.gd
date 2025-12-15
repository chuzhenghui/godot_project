extends Node2D

@onready var level_utils: level_utils = $LevelUtils

#当前关卡
var is_level = 1;
var max_level = 45;

var current_level = preload("res://scenes/level/Level_1.tscn")
var next_level = preload("res://scenes/level/Level_2.tscn")


func _ready() -> void:
	Main.switch_is_level.connect(_on_switch_is_level)
	print(level_utils)
	
	
func _on_switch_is_level():
	print("Level Complete")
	print(level_utils)
	await level_utils.fade(1.0, 1.5).finished
	print("Faded 0ut")
	get_child(0).queue_free()
	var new_level = next_level.instantiate()
	add_child(new_level)
	await level_utils.fade(0.0,1.5).finished
	print("Faded In")
