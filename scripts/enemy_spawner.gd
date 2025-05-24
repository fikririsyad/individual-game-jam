extends Node

@export var spawn_interval := 10.0

func _ready() -> void:  
	$EnemySpawnTimer.wait_time = spawn_interval
	$EnemySpawnTimer.start()  

func _on_enemy_spawn_timer_timeout() -> void:  
	if get_tree().get_nodes_in_group("enemy").size() < 3:
		var enemy = preload("res://scenes/Enemy.tscn").instantiate()  
		enemy.position = get_spawn_position()
		get_parent().add_child(enemy)

func get_spawn_position() -> Vector2:
	var side = randi() % 4

	match side:
		0: # Top edge
			return Vector2(random_grid_x(), Global.MIN_Y)
		1: # Left edge
			return Vector2(Global.MIN_X, random_grid_y())
		2: # Bottom edge
			return Vector2(random_grid_x(), Global.MAX_Y)
		3: # Right edge
			return Vector2(Global.MAX_X, random_grid_y())
		_:
			return Vector2(Global.MAX_X, Global.MAX_Y)

# Returns a random X coordinate that is aligned to the grid
func random_grid_x() -> int:
	var cell_count = int((Global.MAX_X - Global.MIN_X) / Global.GRID_SIZE)
	return Global.MIN_X + Global.GRID_SIZE * randi() % (cell_count + 1)

# Returns a random Y coordinate that is aligned to the grid
func random_grid_y() -> int:
	var cell_count = int((Global.MAX_Y - Global.MIN_Y) / Global.GRID_SIZE)
	return Global.MIN_Y + Global.GRID_SIZE * randi() % (cell_count + 1)
	
