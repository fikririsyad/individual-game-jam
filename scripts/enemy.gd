extends Area2D

@export var speed := 100.0
@export var damage := 0.25
@export var unclaim_cooldown := 1.0  # Cooldown time after unclaiming a tile

@onready var basemap: TileMapLayer = get_node("../Layers/BaseLayer")
@onready var claimmap: TileMapLayer = get_node("../Layers/ClaimLayer")
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var is_moving := false
var target_position := Vector2()
var current_grid_position := Vector2i()
var is_cooling_down := false
var cooldown_timer := 0.0

func _ready() -> void:
	speed *= randf_range(0.9, 1.1)
	current_grid_position = basemap.local_to_map(position) # Set initial grid position
	position = basemap.map_to_local(current_grid_position)

func _physics_process(delta: float) -> void:
	if is_cooling_down:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			is_cooling_down = false
			cooldown_timer = 0.0
		return
		
	if is_moving:
		# Continue moving toward target
		var step_size = speed * delta
		position = position.move_toward(target_position, step_size)
		
		# Check if we've reached the target position
		if position.is_equal_approx(target_position):
			is_moving = false
			current_grid_position = basemap.local_to_map(position)
			
			# Check if we're on a claimed tile
			try_unclaim_tile()
	else:
		# Find next tile to move to
		var next_position = get_next_grid_position()
		if next_position != current_grid_position:
			target_position = basemap.map_to_local(next_position)
			is_moving = true

func get_next_grid_position() -> Vector2i:
	# Try to find the closest claimed tile
	var closest_claimed_tile = find_closest_claimed_tile()
	
	if closest_claimed_tile:
		# Move toward the closest claimed tile
		var direction = (closest_claimed_tile - current_grid_position).sign()
		
		# Only move in one direction at a time (grid-based movement)
		if direction.x != 0 and direction.y != 0:
			# Randomly choose whether to move horizontally or vertically
			if randf() > 0.5:
				direction.y = 0
			else:
				direction.x = 0
				
		return current_grid_position + Vector2i(direction)
	else:
		# If no claimed tiles, move toward player
		var player_grid_pos = basemap.local_to_map(player.position)
		var direction = (player_grid_pos - current_grid_position).sign()
		
		# Only move in one direction at a time
		if direction.x != 0 and direction.y != 0:
			if randf() > 0.5:
				direction.y = 0
			else:
				direction.x = 0
				
		return current_grid_position + Vector2i(direction)

func find_closest_claimed_tile() -> Vector2i:
	var claimed_tiles = player.claimed_tiles
	
	if claimed_tiles.is_empty():
		return Vector2i()  # Return empty vector if no claimed tiles
		
	var closest_tile = null
	var closest_distance = INF
	
	for tile_pos_key in claimed_tiles.keys():
		# Convert string key to Vector2i if needed
		var tile_pos = tile_pos_key
		if typeof(tile_pos_key) == TYPE_STRING:
			# If your claimed_tiles dictionary stores string keys, parse them
			var coords = tile_pos_key.split(",")
			tile_pos = Vector2i(int(coords[0]), int(coords[1]))
		
		 # No color check - enemy can target any claimed tile
		var distance = current_grid_position.distance_squared_to(tile_pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_tile = tile_pos
	
	return closest_tile if closest_tile else Vector2i()

func try_unclaim_tile() -> void:
	# Check if current position is a claimed tile (no color check)
	if current_grid_position in player.claimed_tiles:
		# Unclaim the tile
		player.claimed_tiles.erase(current_grid_position)
		claimmap.erase_cell(current_grid_position)
		player.emit_signal("score_updated", player.claimed_tiles.size())
		
		# Start cooldown period after successfully unclaiming a tile
		is_cooling_down = true
		cooldown_timer = unclaim_cooldown

func _get_tile_color(tile_pos: Vector2i) -> String:
	var atlas_coords = basemap.get_cell_atlas_coords(tile_pos)
	
	match atlas_coords:
		Vector2i(0, 0): return "red"
		Vector2i(1, 0): return "blue"  
		Vector2i(2, 0): return "yellow"
		_: return "neutral"

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
