extends Camera2D

@export var player: CharacterBody2D


func _ready() -> void:
	enabled = player.is_local_player


func shake(duration: float = 0.5, intensity: float = 1.0) -> void:
	if not player.is_local_player:
		return

	var shake_tween = create_tween()
	shake_tween.tween_method(
		func(progress: float):
			var current_intensity = intensity * (1.0 - progress)

			offset = Vector2(
				randf_range(-current_intensity, current_intensity),
				randf_range(-current_intensity, current_intensity)
			),
		0.0,
		1.0,
		duration
	)
	shake_tween.finished.connect(func(): offset = Vector2.ZERO)
