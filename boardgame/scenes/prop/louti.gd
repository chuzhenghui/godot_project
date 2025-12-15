extends Area2D





func _on_body_entered(body: Node2D) -> void:
	print('进入楼梯')
	Main.switch_is_level.emit()
