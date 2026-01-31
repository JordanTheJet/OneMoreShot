class_name InteractionPromptUI
extends Control

## UI component that shows gesture hints and progress

@onready var container: VBoxContainer = $Container
@onready var hint_label: Label = $Container/HintLabel
@onready var progress_bar: ProgressBar = $Container/ProgressBar
@onready var gesture_icon: TextureRect = $Container/IconContainer/GestureIcon

var _is_visible: bool = false
var _current_interaction: Enums.InteractionType = Enums.InteractionType.NONE


func _ready() -> void:
	visible = false
	progress_bar.value = 0.0

	if GestureDetector:
		GestureDetector.gesture_progress.connect(_on_gesture_progress)


func show_hint(text: String) -> void:
	hint_label.text = text
	progress_bar.value = 0.0
	_fade_in()


func show_default_hint(interaction_type: Enums.InteractionType) -> void:
	_current_interaction = interaction_type

	match interaction_type:
		Enums.InteractionType.CATCH:
			hint_label.text = "Raise both hands to catch"
		Enums.InteractionType.PASS:
			hint_label.text = "Push forward to pass"
		Enums.InteractionType.BALLOON:
			hint_label.text = "Gently push forward"
		_:
			hint_label.text = ""
			return

	progress_bar.value = 0.0
	_fade_in()


func hide_prompt() -> void:
	_fade_out()


func _fade_in() -> void:
	if _is_visible:
		return

	_is_visible = true
	visible = true
	modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _fade_out() -> void:
	if not _is_visible:
		return

	_is_visible = false

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished

	visible = false
	progress_bar.value = 0.0


func _on_gesture_progress(gesture_type: Enums.InteractionType, progress: float) -> void:
	if gesture_type == _current_interaction and _is_visible:
		progress_bar.value = progress
