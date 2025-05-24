extends Node

var button_sfx: AudioStreamPlayer
var bgm_player: AudioStreamPlayer

func _ready() -> void:
	button_sfx = AudioStreamPlayer.new()
	button_sfx.stream = load("res://assets/audio/button_click.wav")  # Your file path
	button_sfx.volume_db = -10
	add_child(button_sfx)
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = load("res://assets/audio/bgm.wav")
	bgm_player.volume_db = -15
	bgm_player.bus = "Music"
	bgm_player.autoplay = true
	add_child(bgm_player)

func play_button_sfx() -> void:
	button_sfx.play()

func play_bgm() -> void:
	if not bgm_player.playing:
		bgm_player.play()

func restart_bgm() -> void:
	bgm_player.stop()  # Ensure playback stops
	bgm_player.play()

func set_bgm_volume(volume_db: float) -> void:
	bgm_player.volume_db = volume_db
