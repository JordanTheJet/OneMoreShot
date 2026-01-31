extends Node

## Manages scene-to-scene transitions (dissolve, fade to white/black)

signal transition_started(type: Enums.TransitionType)
signal transition_midpoint()
signal transition_completed()

const DEFAULT_DISSOLVE_DURATION := 1.2
const DEFAULT_FADE_WHITE_DURATION := 1.5
const DEFAULT_FADE_BLACK_DURATION := 1.0

var _transition_layer: CanvasLayer
var _color_rect: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	_setup_transition_layer()


func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100  # Above everything
	add_child(_transition_layer)

	_color_rect = ColorRect.new()
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.visible = false
	_transition_layer.add_child(_color_rect)


func is_transitioning() -> bool:
	return _is_transitioning


func transition_to_scene(scene_path: String, transition_type: Enums.TransitionType = Enums.TransitionType.DISSOLVE, duration: float = 0.0) -> void:
	if _is_transitioning:
		push_warning("Transition already in progress")
		return

	_is_transitioning = true
	transition_started.emit(transition_type)

	match transition_type:
		Enums.TransitionType.DISSOLVE:
			await _do_dissolve_transition(scene_path, duration if duration > 0 else DEFAULT_DISSOLVE_DURATION)
		Enums.TransitionType.FADE_WHITE:
			await _do_fade_transition(scene_path, Color.WHITE, duration if duration > 0 else DEFAULT_FADE_WHITE_DURATION)
		Enums.TransitionType.FADE_BLACK:
			await _do_fade_transition(scene_path, Color.BLACK, duration if duration > 0 else DEFAULT_FADE_BLACK_DURATION)
		_:
			# Instant transition
			get_tree().change_scene_to_file(scene_path)

	_is_transitioning = false
	transition_completed.emit()


func _do_dissolve_transition(scene_path: String, duration: float) -> void:
	# For dissolve, we fade to black and back (simplified approach without screenshot)
	await _do_fade_transition(scene_path, Color.BLACK, duration)


func _do_fade_transition(scene_path: String, fade_color: Color, duration: float) -> void:
	_color_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0)
	_color_rect.visible = true

	var half_duration := duration / 2.0

	# Fade out
	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 1.0, half_duration)
	await tween.finished

	transition_midpoint.emit()

	# Change scene
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to load scene: %s" % scene_path)
		_color_rect.visible = false
		return

	# Wait a frame for scene to load
	await get_tree().process_frame

	# Fade in
	tween = create_tween()
	tween.tween_property(_color_rect, "color:a", 0.0, half_duration)
	await tween.finished

	_color_rect.visible = false


## Quick fade to black (useful for ending)
func fade_to_black(duration: float = 1.0) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.visible = true

	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 1.0, duration)
	await tween.finished


## Fade from current state to clear
func fade_from_black(duration: float = 1.0) -> void:
	_color_rect.color = Color(0, 0, 0, 1)
	_color_rect.visible = true

	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 0.0, duration)
	await tween.finished

	_color_rect.visible = false
	_is_transitioning = false


## Flash white (for dramatic moments)
func flash_white(duration: float = 0.3) -> void:
	_color_rect.color = Color(1, 1, 1, 1)
	_color_rect.visible = true

	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 0.0, duration)
	await tween.finished

	_color_rect.visible = false
