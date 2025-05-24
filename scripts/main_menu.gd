extends CanvasLayer

func _ready():
	Audio.play_bgm()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
