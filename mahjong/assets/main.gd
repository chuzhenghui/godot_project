extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var row: int = 1
var col: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 应用到一个 Sprite2D 节点
	sprite_2d.texture = get_atlas_texture_from_index(row,col)



func get_atlas_texture_from_index(index: int,index2: int) -> AtlasTexture:
	var x = 10 
	var y = 2
	var region = Rect2(index*x, index2*y, 44, 60)
	
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = preload("res://assets/deck_mahjong_light_0.png")
	atlas_texture.region = region
	return atlas_texture
