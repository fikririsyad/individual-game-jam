extends Node

@export var spawn_interval := 10.0

@onready var basemap: TileMapLayer = get_node("../Layers/BaseLayer")
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	randomize()
	$PowerUpSpawnTimer.start(spawn_interval)

func _on_power_up_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("powerup").size() < 5:
		var powerup = get_random_powerup().instantiate()
		powerup.position = get_random_position()
		get_parent().add_child(powerup)
		$PowerUpSpawnTimer.start(spawn_interval)

func get_random_powerup() -> PackedScene:
	return preload("res://scenes/SpeedPowerUp.tscn") if randf() > 0.5 else preload("res://scenes/ShieldPowerUp.tscn")

func get_random_position() -> Vector2:
	# Spawn anywhere within bounds, aligned to grid
	return Vector2(
		random_grid_x(),
		random_grid_y()
	)

func random_grid_x() -> int:
	var num_cells = (Global.MAX_X - Global.MIN_X) / Global.GRID_SIZE
	var cell_index = randi() % (num_cells + 1)
	return Global.MIN_X + (cell_index * Global.GRID_SIZE)

func random_grid_y() -> int:
	var num_cells = (Global.MAX_Y - Global.MIN_Y) / Global.GRID_SIZE
	var cell_index = randi() % (num_cells + 1)
	return Global.MIN_Y + (cell_index * Global.GRID_SIZE)
