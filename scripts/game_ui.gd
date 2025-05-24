extends CanvasLayer  

# LIVES SYSTEM (COPIED FROM LivesUI.gd)  
@export var heart_empty: Texture2D  
@export var heart_quarter: Texture2D  
@export var heart_half: Texture2D  
@export var heart_three_quarters: Texture2D  
@export var heart_full: Texture2D  

@onready var lives_container = $MarginContainer/HBoxContainer/LivesContainer  # Path to your HBoxContainer  
@onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel  
@onready var timer_label = $MarginContainer/HBoxContainer/VBoxContainer/TimerLabel  

const GAME_DURATION := 180.0

var hearts: Array[TextureRect] = []  
var score := 0
var time_remaining := GAME_DURATION
var is_game_active := true

func _ready() -> void:  
	# Initialize hearts  
	var player = get_tree().get_first_node_in_group("player")  
	if player:
		initialize_hearts(player.max_lives)  
		player.lives_changed.connect(update_hearts)  
		player.score_updated.connect(update_score)
	
	update_timer_display()

# --- LIVES CODE (FROM LivesUI.gd) ---  
func initialize_hearts(max_hearts: int) -> void:  
	# Clear existing hearts  
	for heart in hearts:  
		heart.queue_free()  
	hearts.clear()  

	# Create new hearts  
	for i in range(max_hearts):  
		var heart = TextureRect.new()  
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  
		heart.texture = heart_full  
		lives_container.add_child(heart)  # Add to LivesContainer, NOT self!  
		hearts.append(heart)  

func update_hearts(current: float, _maximum: int) -> void:  
	var full_hearts = floor(current)  
	var partial_heart = current - full_hearts  

	for i in range(hearts.size()):  
		if i < full_hearts:  
			hearts[i].texture = heart_full  
		elif i == full_hearts and partial_heart > 0:  
			if partial_heart <= 0.25:  
				hearts[i].texture = heart_quarter  
			elif partial_heart <= 0.5:  
				hearts[i].texture = heart_half  
			elif partial_heart <= 0.75:  
				hearts[i].texture = heart_three_quarters  
			else:  
				hearts[i].texture = heart_full  
		else:  
			hearts[i].texture = heart_empty  

func update_score(new_score: int) -> void:  
	score = new_score  
	score_label.text = "SCORE: %d" % score  
	
func update_timer_display() -> void:
	# Show whole seconds only (no decimals)
	timer_label.text = "TIME: %d" % ceil(time_remaining)

func _process(delta: float) -> void:  
	if !is_game_active:
		return
		
	time_remaining = max(0, time_remaining - delta)
	update_timer_display()
	
	if time_remaining <= 0:
		is_game_active = false
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.game_over()
