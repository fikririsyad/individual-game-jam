extends PowerUp


@export var duration := 3.0

func apply_effect(area: Area2D) -> void:
	area.activate_shield(duration)
