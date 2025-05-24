extends TextureButton

@export var button_text := "Button":
	set(value):
		button_text = value
		if has_node("Label"):
			$Label.text = value

func _ready() -> void:
	pressed.connect(Audio.play_button_sfx)
	$Label.text = button_text
