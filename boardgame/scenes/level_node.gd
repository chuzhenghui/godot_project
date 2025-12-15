extends Node2D

@onready var level_utils: level_utils = $LevelUtils

#当前关卡
var current_level = 1;

const level_path = "res://scenes/level/"

#简单的定义关卡数据
var level_data:Array[Resource]


func _ready() -> void:
	Main.switch_is_level.connect(_on_switch_is_level)
	print(level_utils)
	
	var files = DirAccess.get_files_at(level_path)
	for file_name in files:
		level_data.append(load(level_path + file_name))
	
	
func _on_switch_is_level():
	print("Level Complete")
	print(level_utils)
	await level_utils.fade(1.0, 1.5).finished
	print("Faded 0ut")
	
	var level_data_array : Array[Node] = find_children("Level*", "Node2D")
	
	for data in level_data_array:
		print(data)
		if data is Node2D:
			data.queue_free()
	
	current_level += 1
	var new_level = level_data[current_level-1].instantiate()
	add_child(new_level)
	
	await level_utils.fade(0.0,1.5).finished
	print("Faded In")
