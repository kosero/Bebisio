extends Node


@onready var ham_sound: AudioStreamPlayer = %HamSound

var counter: int = 0


func TakeCookie() -> void:
	counter += 1
	ham_sound.play()
