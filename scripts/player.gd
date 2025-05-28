extends Area2D

@export var red_texture: Texture2D
@export var blue_texture: Texture2D
@export var yellow_texture: Texture2D
@export var max_lives := 5.0  # Number of hearts (3, 4, or 5)

@onready var basemap: TileMapLayer = get_node("../Layers/BaseLayer")  # Layer 0 - base tiles
@onready var claimmap: TileMapLayer = get_node("../Layers/ClaimLayer")  # Layer 1 - claim overlay
@onready var sprite = $Sprite2D

const SPEED := 200
const INIT_SWITCH_COOLDOWN := 1.0

# Score and lives
var score := 0
var current_lives := max_lives  # Float for partial hearts (each heart = 1.0)
var current_color := "red"

# Claiming
var claimed_tiles := {}  # Dictionary: tile_position -> true/false (claimed)
var total_tiles := 0  # Populated in _ready()

# Switch and move
var safe_time := 0.0
var switch_color_timer := 0.0
var switch_cooldown := INIT_SWITCH_COOLDOWN
var is_moving := false
var target_position := Vector2()
var current_speed := SPEED

# Damage, heal, and power ups
var damage_timer := 0.0
var heal_timer := 0.0
var speed_boost_active := false
var shield_active := false

# Signal to notify UI when lives and score change
signal lives_changed(current: float, maximum: int)
signal score_updated(new_score: int) 

func _ready() -> void:
	# Get total tiles in the grid (e.g., 20x20)
	total_tiles = basemap.get_used_cells().size()  # Layer 0 = base tiles

func _physics_process(delta: float) -> void:
	var current_tile = basemap.local_to_map(position)
	
	if is_moving:
		# Continue moving toward target
		var step_size = current_speed * delta
		position = position.move_toward(target_position, step_size)
		
		# Check if we've reached the target position
		if position.is_equal_approx(target_position):
			is_moving = false
	else:
		# Only accept new movement input when not already moving
		var direction = Vector2.ZERO
		
		# Check for movement input one direction at a time (priority order)
		if Input.is_action_pressed("move_up"):
			direction = Vector2.UP
		elif Input.is_action_pressed("move_down"):
			direction = Vector2.DOWN
		elif Input.is_action_pressed("move_left"):
			direction = Vector2.LEFT
		elif Input.is_action_pressed("move_right"):
			direction = Vector2.RIGHT
		
		if direction != Vector2.ZERO:
			# Calculate potential new position
			var potential_target = position + direction * Global.GRID_SIZE
			
			# Check if new position is within boundaries
			if is_within_boundaries(potential_target):
				target_position = potential_target
				is_moving = true
				
			else:
				$BumpSound.play()
				
	handle_tile_claiming(current_tile, delta)
	
	if get_tile_color(current_tile) != current_color:
		safe_time = 0.0
		damage_timer += delta
		if damage_timer >= 0.5:
			take_damage(1)
			damage_timer = 0.0
	else:
		heal_timer += delta
		safe_time += delta
		damage_timer = 0.0  # Reset damage if back on safe tile
		if safe_time >= 1.5 and heal_timer >= 1.0:
			heal(0.25)
			heal_timer = 0.0
			
	switch_color_timer += delta

func handle_tile_claiming(tile_pos: Vector2i, delta: float) -> void:
	var tile_color = get_tile_color(tile_pos)
	
	if tile_color == current_color or shield_active:
		# Claim tile instantly if not already claimed
		if not claimed_tiles.get(tile_pos, false):
			claimed_tiles[tile_pos] = true
			$MatchSound.play()
			emit_signal("score_updated", claimed_tiles.size() + score)  # Reuse score for claimed count
			claimmap.set_cell(tile_pos, 0, Vector2i(0, 0))  # Layer 1 = claimed overlay
			check_win_condition()

func get_tile_color(tile_pos: Vector2i) -> String:
	# Match your TileMap's source IDs to colors (adjust based on your setup)
	var atlas_coords = basemap.get_cell_atlas_coords(tile_pos)
	
	match atlas_coords:
		Vector2i(0, 0): return "red"
		Vector2i(1, 0): return "blue"  
		Vector2i(2, 0): return "yellow"
		_: return "neutral"

func check_win_condition() -> void:
	if claimed_tiles.size() + score > 100:
		var end_screen = get_node("../EndScreenUI")
		end_screen.show_game_over(true, claimed_tiles.size() + score, get_node("../GameUI").time_remaining)

func _input(event: InputEvent) -> void:
	if switch_color_timer >= switch_cooldown:
		if event.is_action_pressed("red"):
			switch_color("red")
		elif event.is_action_pressed("blue"):
			switch_color("blue")
		elif event.is_action_pressed("yellow"):
			switch_color("yellow")

func switch_color(color: String) -> void:
	if current_color == color:
		return

	match color:
		"red":
			sprite.texture = red_texture
		"blue":
			sprite.texture = blue_texture
		"yellow":
			sprite.texture = yellow_texture
		_:
			return

	current_color = color
	switch_color_timer = 0.0

func is_within_boundaries(pos: Vector2) -> bool:
	return pos.x >= Global.MIN_X and pos.x <= Global.MAX_X and \
	pos.y >= Global.MIN_Y and pos.y <= Global.MAX_Y

func take_damage(amount: float = 0.25) -> void:
	if shield_active:
		return
	current_lives = max(0, current_lives - amount)
	$HitSound.play()
	emit_signal("lives_changed", current_lives, max_lives)
	
	if current_lives <= 0:
		game_over()

func heal(amount: float = 0.25) -> void:
	var new_lives = current_lives + amount
	if new_lives > max_lives:
		return
	current_lives = new_lives
	$HealSound.play()
	emit_signal("lives_changed", current_lives, max_lives)

func activate_speed_boost(multiplier: float, duration: float) -> void:
	current_speed = SPEED * multiplier
	modulate = Color.SILVER
	$SpeedTimer.start(duration)

func activate_shield(duration: float) -> void:
	shield_active = true
	modulate = Color.BLACK
	$ShieldTimer.start(duration)

func _on_speed_timer_timeout() -> void:
	modulate = Color.WHITE
	current_speed = SPEED

func _on_shield_timer_timeout() -> void:
	modulate = Color.WHITE
	shield_active = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		$HitSound.play()
		score += 5
		emit_signal("score_updated", claimed_tiles.size() + score)
		take_damage(1)
		area.queue_free()
		check_win_condition()
	elif area.is_in_group("powerup"):
		area.queue_free()

func game_over() -> void:
	var end_screen = get_node("../EndScreenUI")
	end_screen.show_game_over(false, claimed_tiles.size() + score, get_node("../GameUI").time_remaining)
