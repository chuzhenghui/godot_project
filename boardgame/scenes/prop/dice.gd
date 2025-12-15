extends Node2D
class_name Dice

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var num :int = 0

var original_position :Vector2

func _ready() -> void:
	
	Main.execute_dice.connect(_on_execute_dice)
		
	original_position = position


func _on_execute_dice(num: int) -> void:
	
	animated_sprite_2d.play("idle_"+str(num))
	
	jump_to_center_with_bounce()
	
	# 等待2秒后跳回
	await get_tree().create_timer(2.0).timeout
	
	jump_back_to_original()
	


func jump_to_center_with_bounce():
	var tween = create_tween()
	var viewport = get_viewport().get_visible_rect()
	var center = viewport.size / 2
	
	# 创建弹跳路径
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# 首次弹跳（较高）
	tween.tween_property(self, "position:y", center.y - 250, 0.3).from_current()
	tween.tween_property(self, "position:y", center.y + 200, 0.2)
	#tween.tween_property(self, "position:y", center.y - 150, 0.2)
	#tween.tween_property(self, "position:y", center.y + 100, 0.2)
	tween.tween_property(self, "position:y", center.y - 60, 0.15)
	tween.tween_property(self, "position:y", center.y + 30, 0.1)
	tween.tween_property(self, "position:y", center.y, 0.05)
	
	# 同时水平移动到中心
	var horizontal_tween = create_tween()
	horizontal_tween.tween_property(self, "position:x", center.x, 1.0).from_current()
	
	await tween.finished
	await horizontal_tween.finished
	
func jump_back_to_original():
	var tween = create_tween()
	
	# 第二阶段：跳回原始位置
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	# 垂直弹跳回原始位置
	#tween.tween_property(self, "position:y", original_position.y - 80, 0.25)
	#tween.tween_property(self, "position:y", original_position.y + 40, 0.15)
	#tween.tween_property(self, "position:y", original_position.y - 20, 0.1)
	tween.tween_property(self, "position:y", original_position.y, 0.55)
	
	# 同时水平移动回原始位置
	var horizontal_tween = create_tween()
	horizontal_tween.tween_property(self, "position:x", original_position.x, 0.55).from_current()
	
