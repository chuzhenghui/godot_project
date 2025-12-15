extends Control


@export var consumption_jb :int = 0
@export var consumption_hp :int = 0
@export var type :int = 0


@onready var texture_rect: TextureRect = $Panel/ColorRect/TextureRect
@onready var label_1: Label = $Panel/ColorRect/VBoxContainer/Label1
@onready var label_2: Label = $Panel/ColorRect/VBoxContainer/Label2
@onready var label_3: Label = $Panel/ColorRect/VBoxContainer/Label3


enum item_type{
	sbys,#双倍药水	双倍掷骰点数 	(一次性)	Used
	mlgjz,#穆里根卷轴	重骰	(一次性)	Used
	tp,#突破     穿墙 (一次性)
	xc,#小吃     恢复3HP
	xc_2,#中型点心    恢复6HP
	xc_3,#丰盛小吃	  恢复9HP
	db,#赌博     掷骰：如果你骰到4+，获得10.其他情况，一无所获.
	jbrc, #金币热潮 在下一层的金币和宝箱中获得的数量翻倍
	mfd #魔法盾   仅在下一层提供隐身.尽情享受吧！
}


 


func _on_button_button_down() -> void:
	print('购买')
