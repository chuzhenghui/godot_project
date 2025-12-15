extends Node2D
class_name main

@onready var dice: Node2D = %Dice
@onready var level_utils: level_utils = $LevelUtils
@onready var level_node: Node2D = $level_node



var HP :int = 10;
var MONEY :int = 0;
var YS :int = 0;

# 数据管理信号
signal hp_score_changed(hp:int)
signal money_score_changed(money:int)
signal ys_score_changed(money:int)
# 扔骰子信号
signal execute_dice(num:int)


# 传送信号方法
signal teleport_position(pp:Vector2)
# 是否执行了传送
var is_teleport :bool = false


#切换关卡
signal switch_is_level()


func _ready() -> void:
	pass
	


func hp_take_damage(num: int):
	HP += num
	hp_score_changed.emit(HP)
	
func money_take_damage(num: int):
	MONEY += num
	money_score_changed.emit(MONEY)
	
func ys_take_damage(num: int):
	YS += num
	ys_score_changed.emit(YS)

func execute_dice_damage(num: int):
	execute_dice.emit(num)
	
func main_switch_is_level():
	switch_is_level.emit()

	
#func execute_dice() -> int:
	#
	#animated_sprite_2d.play("idle_"+str(num))
	#
	#return num
 
