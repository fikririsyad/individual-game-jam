extends CanvasLayer  

@onready var title_label = $Background/MarginContainer/VBoxContainer/TitleLabel
@onready var score_label = $Background/MarginContainer/VBoxContainer/ScoreTimerMarginContainer/VBoxContainer/ScoreLabel
@onready var time_label = $Background/MarginContainer/VBoxContainer/ScoreTimerMarginContainer/VBoxContainer/TimerLabel

func show_game_over(win: bool, score: int, time: float) -> void:
	if win:
		title_label.text = "You Win"
		title_label.modulate = Color.GOLD
		$WinSound.play()
	else:
		title_label.text = "You Lose"
		title_label.modulate = Color.FIREBRICK
		$LoseSound.play()
		
	score_label.text = "Score: %d" % score  
	time_label.text = "Time remaining: %.1fs" % time  
	visible = true  
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	Audio.restart_bgm()
	get_tree().paused = false  
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	Audio.restart_bgm()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
