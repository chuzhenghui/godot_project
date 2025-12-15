extends CanvasLayer

@onready var hp: Label = $VBoxContainer/HP
@onready var jb: Label = $VBoxContainer/JB
@onready var ys: Label = $VBoxContainer/YS



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.hp_score_changed.connect(_on_hp_score_changed)
	Main.money_score_changed.connect(_on_money_score_changed)
	Main.ys_score_changed.connect(_on_ys_score_changed)
	
	hp.text = "生命：" + str(Main.HP)
	jb.text = "金币：" + str(Main.MONEY)
	ys.text = "钥匙：" + str(Main.YS)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_hp_score_changed(num: int) -> void:
	hp.text = "生命：" + str(num)
	
	
func _on_money_score_changed(num: int) -> void:
	jb.text = "金币：" + str(num)
	
func _on_ys_score_changed(num: int) -> void:
	ys.text = "钥匙：" + str(num)
