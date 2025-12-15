extends CharacterBody2D

const grid_size: int = 64
const move_speed: float = 400

# 初始化位置 # 
@export var player_x: float = 800.0
@export var player_y: float = 288.0
@export var snap_to_grid: bool = true


# === 回合制相关变量 ===
@export var current_turn_direction_array: Array[Vector2]
@export var current_turn_direction: Vector2 = Vector2.ZERO  # 当前回合的移动方向
@export var max_moves_per_turn: int = 3  # 每回合最大移动次数
@export var moves_left: int = 0  # 当前回合剩余移动次数
var turn_active: bool = true     # 回合是否活跃


# === 移动相关变量 ===
var is_moving: bool = false # 是否可移动
var target_position: Vector2 # 目标位置
var current_grid_pos: Vector2i # 当前位置
var velocity_vector: Vector2 = Vector2.ZERO # 速度向量

# === 状态追踪 ===
var moves_made_this_turn: int = 0  # 本回合已移动次数


func _ready():
	# 确保角色初始位置对齐到网格
	position = Vector2(player_x, player_y)
	current_grid_pos = world_to_grid(position)
	
	# 如果启用网格对齐，确保初始位置对齐
	if snap_to_grid:
		position = grid_to_world_center(current_grid_pos)
	
	# 链接传送信号 
	Main.teleport_position.connect(_on_teleport_position)
	
	# 初始化回合
	if(moves_left == 0):
		reset_turn()
	
	
	
func _physics_process(delta):
	if(moves_left != 0 and current_turn_direction != Vector2.ZERO):
		_on_next_step_direction()
	
	if turn_active and !is_moving:
		handle_mouse_input()
	elif is_moving:
		handle_movement(delta)

func handle_mouse_input():
	if Input.is_action_just_pressed("click") and moves_left > 0:
		var mouse_pos = get_global_mouse_position()
		var target_grid_pos = world_to_grid(mouse_pos)
		
		# 检查是否相邻（8方向）
		if is_adjacent_grid(current_grid_pos, target_grid_pos):
			# 计算移动方向向量
			var direction = calculate_direction(current_grid_pos, target_grid_pos)
			# === 回合制方向检查 ===
			if current_turn_direction == Vector2.ZERO and direction in current_turn_direction_array:
				current_turn_direction = direction
				# 方向相同，允许移动
				start_movement(target_grid_pos, direction)
			elif direction == current_turn_direction:
				# 方向相同，允许移动
				start_movement(target_grid_pos, direction)
			else:
				# 方向不同，不允许移动
				print("本回合只能向", direction_to_string(current_turn_direction), "方向移动")
				# 可以添加视觉反馈，比如闪烁角色或显示提示
				show_direction_hint()

func start_movement(target_grid_pos: Vector2i, direction: Vector2):
	# 设置目标位置
	target_position = grid_to_world_center(target_grid_pos)
	
	# 设置速度向量
	velocity_vector = direction.normalized() * move_speed
	
	# 开始移动
	is_moving = true
	
	# 预扣移动次数（实际在移动完成后扣除）
	# 这里我们先标记移动开始，等到达目的地后再扣除

func handle_movement(delta):
	# 使用 move_and_slide() 处理移动
	
	# 检查是否已经到达目标位置
	if position.distance_to(target_position) < 5:
		# 到达目标，停止移动
		position = target_position
		velocity = Vector2.ZERO
		is_moving = false
		current_grid_pos = world_to_grid(position)
		
		# === 回合制移动计数 ===
		complete_move()
		return
	
	# 设置速度
	velocity = velocity_vector
	
	# 使用 move_and_slide() 移动
	var collision = move_and_slide()
	
	# 检查碰撞
	if get_slide_collision_count() > 0:
		# 发生碰撞，停止移动并回退到当前位置网格
		handle_collision()
		return
	
	# 更新当前网格位置
	var new_grid_pos = world_to_grid(position)
	if new_grid_pos != current_grid_pos:
		current_grid_pos = new_grid_pos
		
		# 检查是否到达目标网格
		if new_grid_pos == world_to_grid(target_position):
			# 精确对齐到网格中心
			position = grid_to_world_center(new_grid_pos)
			velocity = Vector2.ZERO
			is_moving = false
			
			# === 回合制移动计数 ===
			complete_move()

func complete_move():
	# 完成一次移动
	moves_made_this_turn += 1
	moves_left -= 1
	
	print("移动完成，本回合已移动: ", moves_made_this_turn, " 次，剩余: ", moves_left, " 次")
	
	# 检查是否用完移动次数
	if moves_left <= 0:
		end_turn()

func handle_collision():
	# 处理碰撞
	var collision = get_last_slide_collision()
	if collision:
		print("碰撞到: ", collision.get_collider().name)
		print("碰撞点: ", collision.get_position())
		print("碰撞法线: ", collision.get_normal())
	
	# 停止移动
	velocity = Vector2.ZERO
	is_moving = false
	
	# 对齐到当前网格中心
	if snap_to_grid:
		position = grid_to_world_center(current_grid_pos)
	
	# 碰撞不算完成移动，不扣除移动次数

# === 回合制功能 ===
func reset_turn():
	var dice_num:int = randi_range(1,6)
	Main.execute_dice_damage(dice_num)
	# 等待2秒后跳回
	await get_tree().create_timer(2.0).timeout
	
	# 重置回合
	max_moves_per_turn = dice_num
	moves_left = dice_num
	moves_made_this_turn = 0
	current_turn_direction_array = []
	current_turn_direction = Vector2.ZERO
	if(dice_num == 1 or dice_num == 3 or dice_num == 5):
		current_turn_direction_array.append(Vector2(1, -1))
		current_turn_direction_array.append(Vector2(-1, -1))
		current_turn_direction_array.append(Vector2(-1, 1))
		current_turn_direction_array.append(Vector2(1, 1))
	else:
		current_turn_direction_array.append(Vector2.RIGHT)
		current_turn_direction_array.append(Vector2.UP)
		current_turn_direction_array.append(Vector2.LEFT)
		current_turn_direction_array.append(Vector2.DOWN)
	
	
	turn_active = true
	print("新回合开始！移动次数: ", dice_num)
	print("新回合开始！移动方向: ", current_turn_direction)
	print("新回合开始！移动方向: ", current_turn_direction_array)

func end_turn():
	# 结束当前回合
	turn_active = false
	print("回合结束！")
	
	# 等待一段时间或触发其他事件后开始新回合
	# 这里可以添加结束回合的动画或效果
	
	# 示例：1秒后自动开始新回合
	await get_tree().create_timer(1.0).timeout
	reset_turn()

func manually_end_turn():
	# 手动结束回合（可以在UI按钮中调用）
	if turn_active:
		end_turn()

func skip_turn():
	# 跳过回合（不移动直接结束）
	if turn_active:
		print("跳过回合")
		end_turn()

# === 方向辅助函数 ===
func direction_to_string(direction: Vector2) -> String:
	# 将方向向量转换为字符串描述
	if direction == Vector2.RIGHT:
		return "右"
	elif direction == Vector2(1, -1).normalized():
		return "右上"
	elif direction == Vector2.UP:
		return "上"
	elif direction == Vector2(-1, -1).normalized():
		return "左上"
	elif direction == Vector2.LEFT:
		return "左"
	elif direction == Vector2(-1, 1).normalized():
		return "左下"
	elif direction == Vector2.DOWN:
		return "下"
	elif direction == Vector2(1, 1).normalized():
		return "右下"
	return "未知"
	
var original_modulate = modulate

func show_direction_hint():
	# 显示方向提示（可以在这里添加视觉效果）
	# 例如：闪烁角色颜色、显示箭头等
	
	# 简单的颜色闪烁示例
	# var original_modulate = modulate
	modulate = Color(1, 0.5, 0.5)  # 红色闪烁
	await get_tree().create_timer(0.2).timeout
	modulate = original_modulate

# === 原有函数保持不变 ===
func calculate_direction(current: Vector2i, target: Vector2i) -> Vector2:
	# 计算8方向移动向量
	var diff:Vector2i = target - current
	return diff;
	# 返回对应的8方向向量
	#if diff == Vector2i(1, 0):    # 右
		#return Vector2.RIGHT
	#elif diff == Vector2i(1, -1): # 右上
		#return Vector2(1, -1).normalized()
	#elif diff == Vector2i(0, -1): # 上
		#return Vector2.UP
	#elif diff == Vector2i(-1, -1): # 左上
		#return Vector2(-1, -1).normalized()
	#elif diff == Vector2i(-1, 0): # 左
		#return Vector2.LEFT
	#elif diff == Vector2i(-1, 1): # 左下
		#return Vector2(-1, 1).normalized()
	#elif diff == Vector2i(0, 1):  # 下
		#return Vector2.DOWN
	#elif diff == Vector2i(1, 1):  # 右下
		#return Vector2(1, 1).normalized()
	#
	#return Vector2.ZERO

func world_to_grid(world_pos: Vector2) -> Vector2i:
	# 将世界坐标转换为网格坐标
	return Vector2i(floor(world_pos.x / grid_size), floor(world_pos.y / grid_size))

func grid_to_world_center(grid_pos: Vector2i) -> Vector2:
	# 将网格坐标转换到网格中心的世界坐标
	return Vector2(grid_pos) * grid_size + Vector2(grid_size / 2.0, grid_size / 2.0)

func is_adjacent_grid(current: Vector2i, target: Vector2i) -> bool:
	# 检查目标网格是否在8个相邻位置
	var dx = abs(target.x - current.x)
	var dy = abs(target.y - current.y)
	
	# 8方向相邻：dx和dy都 <= 1 且不同时为0
	return dx <= 1 and dy <= 1 and (dx != 0 or dy != 0)

func _on_next_step_direction() -> void:	
		var next_step_direction:Vector2i = current_grid_pos + Vector2i(current_turn_direction)
		if(next_step_direction in Main.tile_map_array):
			print('改变移动方向')
			current_turn_direction_array = []
			# 返回对应的8方向向量
			if Vector2i(current_turn_direction) == Vector2i(1, 0):    # 右 Vector2.RIGHT
				# 上 Vector2.UP
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2.UP)
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.UP)
				# 下 Vector2.DOWN	
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2.DOWN)
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.DOWN)
				# 右 Vector2.RIGHT	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2.RIGHT)
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.RIGHT)
				
				# 左 Vector2.LEFT
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2.LEFT)
			elif Vector2i(current_turn_direction) == Vector2i(1, -1): # 右上 Vector2(1, -1)
				# 左上 Vector2(-1, -1)	
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2(-1, -1))
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, -1)) 
				# 右上 Vector2(1, -1)
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2(1, -1))
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, -1))
				# 右下 Vector2(1, 1)	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2(1, 1))
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, 1))
					
				# 左下 Vector2(-1, 1)
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2(-1, 1)) 
			elif Vector2i(current_turn_direction) == Vector2i(0, -1): # 上 Vector2.UP
				# 上 Vector2.UP
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2.UP)
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.UP)
				# 左 Vector2.LEFT	
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2.LEFT)
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.LEFT)
				# 右 Vector2.RIGHT	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2.RIGHT)
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.RIGHT)
					
				# 下 Vector2.DOWN	
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2.DOWN)
			elif Vector2i(current_turn_direction) == Vector2i(-1, -1): # 左上 Vector2(-1, -1)
				# 左上 Vector2(-1, -1)	
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2(-1, -1))
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, -1)) 
				# 左下 Vector2(-1, 1)
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2(-1, 1))
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, 1))
				# 右上 Vector2(1, -1)
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2(1, -1))
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, -1))
					
				# 右下 Vector2(1, 1)
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2(1, 1)) 
			elif Vector2i(current_turn_direction) == Vector2i(-1, 0): # 左 Vector2.LEFT
				# 上 Vector2.UP
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2.UP)
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.UP)
				# 下 Vector2.DOWN	
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2.DOWN)
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.DOWN)
				# 左 Vector2.LEFT	
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2.LEFT)
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.LEFT)
					
				# 右 Vector2.RIGHT	
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2.RIGHT)
			elif Vector2i(current_turn_direction) == Vector2i(-1, 1): # 左下 Vector2(-1, 1)
				# 左上 Vector2(-1, -1)	
				var next_step_direction1:Vector2i = current_grid_pos + Vector2i(Vector2(-1, -1))
				if(next_step_direction1 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, -1)) 
				# 左下 Vector2(-1, 1)
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2(-1, 1))
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, 1))
				# 右下 Vector2(1, 1)	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2(1, 1))
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, 1))
					
				# 右上 Vector2(1, -1)
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2(1, -1)) 
			elif Vector2i(current_turn_direction) == Vector2i(0, 1):  # 下 Vector2.DOWN
				# 下 Vector2.DOWN	
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2.DOWN)
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.DOWN)
				# 左 Vector2.LEFT	
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2.LEFT)
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.LEFT)
				# 右 Vector2.RIGHT	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2.RIGHT)
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2.RIGHT)
					
				# 上 Vector2.UP
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2.UP)
			elif Vector2i(current_turn_direction) == Vector2i(1, 1):  # 右下 Vector2(1, 1)
				# 左下 Vector2(-1, 1)
				var next_step_direction2:Vector2i = current_grid_pos + Vector2i(Vector2(-1, 1))
				if(next_step_direction2 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(-1, 1))
				# 右上 Vector2(1, -1)
				var next_step_direction3:Vector2i = current_grid_pos + Vector2i(Vector2(1, -1))
				if(next_step_direction3 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, -1))
				# 右下 Vector2(1, 1)	
				var next_step_direction4:Vector2i = current_grid_pos + Vector2i(Vector2(1, 1))
				if(next_step_direction4 not in Main.tile_map_array):
					current_turn_direction_array.append(Vector2(1, 1))
					
				# 左上 Vector2(-1, -1)
				if(current_turn_direction_array.size() == 0):
					current_turn_direction_array.append(Vector2(-1, -1))	 
					
			current_turn_direction = Vector2.ZERO
			
			print("移动次数: ", moves_left)
			print("移动方向: ", current_turn_direction)
			print("移动方向: ", current_turn_direction_array)
			
			
# === 添加UI控制功能 ===
func _input(event):
	# 添加键盘控制
	#if event.is_action_pressed("end_turn"):
		#manually_end_turn()
	#elif event.is_action_pressed("skip_turn"):
		#skip_turn()
	#elif event.is_action_pressed("reset_turn"):
		#reset_turn()
	pass
		
		
func _on_teleport_position(pp :Vector2) -> void:	
	# 确保角色初始位置对齐到网格
	position = Vector2(pp.x, pp.y)
	current_grid_pos = world_to_grid(position)
	
	# 如果启用网格对齐，确保初始位置对齐
	if snap_to_grid:
		position = grid_to_world_center(current_grid_pos)	
