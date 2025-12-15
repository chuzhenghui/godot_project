extends TileMapLayer
 


func _ready() -> void:
	# 获取所有瓦片地图 位置
	var cells:Array[Vector2i] = get_used_cells()
	
	Main.tile_map_array = cells
	
	print(Main.tile_map_array)
	#if(cells):
		#for data in cells:
			#print(data)
	

	#if Main.tile_map_array:
		#for data in Main.tile_map_array:
			#print(data)

 
