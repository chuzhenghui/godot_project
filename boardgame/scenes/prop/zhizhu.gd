extends Area2D

@export var hp :int = 0;
@onready var label: Label = %Label

func _ready() -> void:
	if hp == 10:
		label.text = '？'
	else:
		label.text = str(hp)

func _on_body_entered(body: Node2D) -> void:
	self.visible = false
	print(body)
	
	if hp == 10:
		var dicenum = randi_range(1,6);
		Main.execute_dice_damage(dicenum)
		
		# 延迟0.6秒后 继续执行
		await get_tree().create_timer(1).timeout
		
		Main.hp_take_damage(-dicenum)
	else:
		Main.hp_take_damage(-hp)
		
	queue_free()
		

	
	
