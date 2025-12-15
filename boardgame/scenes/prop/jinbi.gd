extends Area2D

 

func _on_body_entered(body: Node2D) -> void:

	Main.money_take_damage(+1)
	
	queue_free()
	
	
