extends Area2D




func _on_body_entered(body: Node2D) -> void:
	self.visible = false
	print(body)
	
	var money = randi_range(1,6);
	Main.execute_dice_damage(-money)
	
	# 延迟1秒后 继续执行
	await get_tree().create_timer(1).timeout
	
	Main.money_take_damage(-money)
		
	queue_free()
