extends Area2D

class_name PowerUp

@export var lifespan := 15.0  # Time before despawning

func _ready() -> void:
	$LifespanTimer.start(lifespan)

func _on_lifespan_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		apply_effect(area)
		queue_free()

func apply_effect(area: Area2D) -> void:
	pass
