extends ConfirmationDialog

##确定
#signal confirmed
##取消
#signal canceled

@export var titel_text :String = '请选择';
@export var message_text :String = '是否使用？';
@export var confirm_text :String = '确定';
@export var cancel_text :String = '取消';

 

func _ready() -> void:
	self.get_window().title = titel_text
	self.dialog_text = message_text
	self.ok_button_text = confirm_text
	self.cancel_button_text = cancel_text

 
func _on_confirm_button_button_up() -> void:

	confirmed.emit()


func _on_cancel_button_button_up() -> void:
	canceled.emit()
	

#func _on_confirmed() -> void:
	#print('确认')
	#
	#
#func _on_canceled() -> void:
	#print('取消')
