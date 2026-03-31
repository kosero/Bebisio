extends Node

signal progress_changed(progress: float)
signal load_finished

var loading_screen: PackedScene = preload("uid://jjg7hvv7f75i")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)

func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path

	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)

	progress_changed.connect(Callable(new_load_screen, "_on_progress_changed"))
	load_finished.connect(Callable(new_load_screen, "_on_load_finished"))

	await new_load_screen.loading_screen_ready

	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		push_error("Threaded load başlatılamadı!")

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)

	if progress.size() > 0:
		progress_changed.emit(progress[0])

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass

		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			push_error("Loading error!")

		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			load_finished.emit()
			get_tree().change_scene_to_packed(loaded_resource)
