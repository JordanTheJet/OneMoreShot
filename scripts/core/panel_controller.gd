class_name PanelController
extends Node2D

## Controls panel strip navigation, camera panning, and interaction timing

signal panel_changed(panel_index: int)
signal interaction_required(interaction_type: Enums.InteractionType)
signal interaction_completed(interaction_type: Enums.InteractionType)
signal scene_completed()

@export var panels: Array[PanelData] = []
@export var auto_start: bool = true

var current_panel_index: int = 0
var is_waiting_for_interaction: bool = false
var current_interaction_type: Enums.InteractionType = Enums.InteractionType.NONE

@onready var camera: Camera2D = $Camera2D
@onready var panel_container: Node2D = $PanelContainer
@onready var interaction_prompt: Control = $InteractionPrompt

var _panel_timer: Timer
var _hint_timer: Timer
var _fallback_timer: Timer
var _is_transitioning: bool = false


func _ready() -> void:
	_setup_timers()
	_setup_gesture_connections()

	if auto_start and panels.size() > 0:
		call_deferred("_start_panel", 0)


func _setup_timers() -> void:
	_panel_timer = Timer.new()
	_panel_timer.one_shot = true
	_panel_timer.timeout.connect(_on_panel_timer_timeout)
	add_child(_panel_timer)

	_hint_timer = Timer.new()
	_hint_timer.one_shot = true
	_hint_timer.timeout.connect(_on_hint_timer_timeout)
	add_child(_hint_timer)

	_fallback_timer = Timer.new()
	_fallback_timer.one_shot = true
	_fallback_timer.timeout.connect(_on_fallback_timer_timeout)
	add_child(_fallback_timer)


func _setup_gesture_connections() -> void:
	if GestureDetector:
		GestureDetector.gesture_detected.connect(_on_gesture_detected)


func load_panels(panel_data_array: Array[PanelData]) -> void:
	panels = panel_data_array
	_build_panel_strip()


func _build_panel_strip() -> void:
	# Clear existing panels
	for child in panel_container.get_children():
		child.queue_free()

	var x_offset: float = 0.0

	for i in range(panels.size()):
		var panel_data := panels[i]
		var panel_node := _create_panel_node(panel_data, i)
		panel_node.position.x = x_offset
		panel_container.add_child(panel_node)
		x_offset += panel_data.panel_width


func _create_panel_node(panel_data: PanelData, index: int) -> Node2D:
	var panel_node := Node2D.new()
	panel_node.name = "Panel_%d" % index

	# Create background sprite
	var bg_sprite := Sprite2D.new()
	bg_sprite.name = "Background"
	bg_sprite.centered = false

	if panel_data.background_path != "" and ResourceLoader.exists(panel_data.background_path):
		bg_sprite.texture = load(panel_data.background_path)
	else:
		# Create placeholder colored rectangle
		var placeholder := _create_placeholder_texture(panel_data.panel_width, 1080, index)
		bg_sprite.texture = placeholder

	panel_node.add_child(bg_sprite)

	# Create foreground layers with parallax
	for j in range(panel_data.foreground_layers.size()):
		var fg_path: String = panel_data.foreground_layers[j]
		var fg_sprite := Sprite2D.new()
		fg_sprite.name = "Foreground_%d" % j
		fg_sprite.centered = false

		if fg_path != "" and ResourceLoader.exists(fg_path):
			fg_sprite.texture = load(fg_path)

		# Store parallax depth as metadata
		var depth: float = 0.0
		if j < panel_data.parallax_depths.size():
			depth = panel_data.parallax_depths[j]
		fg_sprite.set_meta("parallax_depth", depth)

		panel_node.add_child(fg_sprite)

	return panel_node


func _create_placeholder_texture(width: int, height: int, index: int) -> ImageTexture:
	var colors := [
		Color(0.2, 0.3, 0.5),   # Blue-gray
		Color(0.3, 0.4, 0.3),   # Green-gray
		Color(0.4, 0.3, 0.3),   # Red-gray
		Color(0.35, 0.3, 0.4),  # Purple-gray
	]

	var color: Color = colors[index % colors.size()]
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)

	# Add panel number indicator
	var center_x := width / 2
	var center_y := height / 2
	var indicator_size := 100

	for x in range(center_x - indicator_size, center_x + indicator_size):
		for y in range(center_y - indicator_size, center_y + indicator_size):
			if x >= 0 and x < width and y >= 0 and y < height:
				var dist := Vector2(x - center_x, y - center_y).length()
				if dist < indicator_size:
					var alpha := 1.0 - (dist / indicator_size)
					var indicator_color := Color(1, 1, 1, alpha * 0.3)
					image.set_pixel(x, y, color.blend(indicator_color))

	return ImageTexture.create_from_image(image)


func _start_panel(index: int) -> void:
	if index < 0 or index >= panels.size():
		scene_completed.emit()
		return

	current_panel_index = index
	var panel_data := panels[index]

	panel_changed.emit(index)

	# Move camera to panel
	var target_x: float = _calculate_panel_camera_x(index)
	camera.position.x = target_x
	camera.position.y = 540  # Center vertically

	# Handle interaction or auto-advance
	if panel_data.interaction_type != Enums.InteractionType.NONE:
		_start_interaction_wait(panel_data)
	else:
		_panel_timer.start(panel_data.duration)


func _calculate_panel_camera_x(index: int) -> float:
	var x: float = 0.0
	for i in range(index):
		x += panels[i].panel_width

	var panel_data := panels[index]
	x += panel_data.panel_width * panel_data.focus_point.x

	return x


func _start_interaction_wait(panel_data: PanelData) -> void:
	is_waiting_for_interaction = true
	current_interaction_type = panel_data.interaction_type

	interaction_required.emit(panel_data.interaction_type)

	# Start hint timer
	if panel_data.hint_delay > 0:
		_hint_timer.start(panel_data.hint_delay)

	# Start fallback timer
	if panel_data.fallback_timeout > 0:
		_fallback_timer.start(panel_data.fallback_timeout)


func _complete_interaction() -> void:
	if not is_waiting_for_interaction:
		return

	_hint_timer.stop()
	_fallback_timer.stop()

	if interaction_prompt:
		interaction_prompt.hide()

	interaction_completed.emit(current_interaction_type)

	is_waiting_for_interaction = false
	current_interaction_type = Enums.InteractionType.NONE

	_transition_to_next_panel()


func _transition_to_next_panel() -> void:
	if _is_transitioning:
		return

	var next_index := current_panel_index + 1

	if next_index >= panels.size():
		scene_completed.emit()
		return

	_is_transitioning = true

	var current_panel := panels[current_panel_index]
	var transition_duration := current_panel.get_transition_duration()

	match current_panel.transition_to_next:
		Enums.TransitionType.PAN:
			await _pan_to_panel(next_index, transition_duration)
		Enums.TransitionType.DISSOLVE:
			# Dissolve is handled at scene level, just move camera
			await _pan_to_panel(next_index, transition_duration)
		_:
			await _pan_to_panel(next_index, 0.3)

	_is_transitioning = false
	_start_panel(next_index)


func _pan_to_panel(index: int, duration: float) -> void:
	var target_x := _calculate_panel_camera_x(index)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position:x", target_x, duration)

	await tween.finished


func _on_panel_timer_timeout() -> void:
	_transition_to_next_panel()


func _on_hint_timer_timeout() -> void:
	if is_waiting_for_interaction and interaction_prompt:
		var panel_data := panels[current_panel_index]
		if panel_data.interaction_hint != "":
			interaction_prompt.show_hint(panel_data.interaction_hint)
		else:
			interaction_prompt.show_default_hint(current_interaction_type)


func _on_fallback_timer_timeout() -> void:
	if is_waiting_for_interaction:
		print("Interaction timeout - auto-advancing")
		_complete_interaction()


func _on_gesture_detected(gesture_type: Enums.InteractionType) -> void:
	if is_waiting_for_interaction and gesture_type == current_interaction_type:
		_complete_interaction()


## Force advance to next panel (for debugging)
func debug_advance() -> void:
	if is_waiting_for_interaction:
		_complete_interaction()
	else:
		_panel_timer.stop()
		_transition_to_next_panel()
