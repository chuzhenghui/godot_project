extends Area2D

@onready var confirm_ation_utils: ConfirmationDialog = $ConfirmAtionUtils


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if(Main.is_teleport):
		confirm_ation_utils.visible = false
		visible = false
	else:
		confirm_ation_utils.visible = true
		visible = false

	
	
func _on_body_exited(body: Node2D) -> void:
	print(body)
	confirm_ation_utils.visible = false
	visible = true
	
	# 延迟2秒后 继续执行
	await get_tree().create_timer(2).timeout
	
	Main.is_teleport = false

func _on_confirm_ation_utils_confirmed() -> void:
	print('执行传送')
	print('执行传送')
	print('执行传送')
	Main.is_teleport = true
	
	var is_position :Vector2 = get_all_marker_positions()
	
	Main.teleport_position.emit(is_position)
	
	print('执行传送')
	print('执行传送')
	print('执行传送')

func _on_confirm_ation_utils_canceled() -> void:
	print('取消')
	print('取消')
	print('取消')


# Godot 4.0+ 推荐使用 find_children()
func get_all_marker_positions() -> Vector2:
	# 获取当前节点下所有 Marker2D 节点
	var markers : Array[Node] = get_parent().find_children("Chuangsong*", "Area2D")
	
	for marker in markers:
		print(marker)
		print(marker.position)
		if marker.position != position and marker is Area2D:
			return marker.position
	return position
