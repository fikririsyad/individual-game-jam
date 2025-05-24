extends PowerUp

@export var speed_multiplier := 1.5
@export var duration := 5.0

func apply_effect(area: Area2D) -> void:
	area.activate_speed_boost(speed_multiplier, duration)
