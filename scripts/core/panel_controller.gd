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
var _panel_started: bool = false  # Guard against rapid panel starts

# Bottom UI for action text
var _action_ui: CanvasLayer
var _action_label: Label
var _action_bg: ColorRect

# Hand overlay
var _hand_overlay: CanvasLayer
var _hand_draw: Control
var _left_landmarks: Array = []
var _right_landmarks: Array = []

# Success effect
var _success_overlay: ColorRect
var _progress_ring: Control


func _ready() -> void:
	_setup_timers()
	_setup_gesture_connections()
	_setup_action_ui()
	_setup_hand_overlay()

	if auto_start and panels.size() > 0:
		call_deferred("_start_panel", 0)


func _setup_action_ui() -> void:
	# Create CanvasLayer for UI
	_action_ui = CanvasLayer.new()
	_action_ui.layer = 10
	add_child(_action_ui)

	# Background panel at bottom (200px tall)
	_action_bg = ColorRect.new()
	_action_bg.color = Color(0, 0, 0, 0.85)
	_action_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_action_bg.offset_top = -200
	_action_bg.offset_bottom = 0
	_action_ui.add_child(_action_bg)

	# Action text label
	_action_label = Label.new()
	_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_action_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_action_label.add_theme_font_size_override("font_size", 42)
	_action_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_action_bg.add_child(_action_label)

	# Initially hidden
	_action_bg.visible = false


func _setup_hand_overlay() -> void:
	# Create CanvasLayer for hand visualization
	_hand_overlay = CanvasLayer.new()
	_hand_overlay.layer = 5  # Below action UI but above game
	add_child(_hand_overlay)

	# Create custom draw control for hands
	_hand_draw = Control.new()
	_hand_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hand_draw.size = Vector2(1024, 1024)  # Match image size
	_hand_draw.draw.connect(_draw_hands)
	_hand_overlay.add_child(_hand_draw)

	# Success flash overlay
	_success_overlay = ColorRect.new()
	_success_overlay.color = Color(1, 1, 1, 0)
	_success_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_success_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hand_overlay.add_child(_success_overlay)

	# Progress ring control
	_progress_ring = Control.new()
	_progress_ring.set_anchors_preset(Control.PRESET_CENTER)
	_progress_ring.size = Vector2(200, 200)
	_progress_ring.position = Vector2(412, 412)  # Center of 1024x1024
	_progress_ring.draw.connect(_draw_progress_ring)
	_progress_ring.visible = false
	_hand_overlay.add_child(_progress_ring)


var _current_progress: float = 0.0

func _draw_hands() -> void:
	if not is_waiting_for_interaction:
		return

	# Draw left hand
	_draw_hand_landmarks(_left_landmarks, Color(0.2, 0.8, 1.0, 0.8))  # Cyan
	# Draw right hand
	_draw_hand_landmarks(_right_landmarks, Color(1.0, 0.5, 0.2, 0.8))  # Orange


func _draw_hand_landmarks(landmarks: Array, color: Color) -> void:
	if landmarks.size() < 21:
		return

	# Hand connections for drawing skeleton
	var connections := [
		[0, 1], [1, 2], [2, 3], [3, 4],      # Thumb
		[0, 5], [5, 6], [6, 7], [7, 8],      # Index
		[0, 9], [9, 10], [10, 11], [11, 12], # Middle
		[0, 13], [13, 14], [14, 15], [15, 16], # Ring
		[0, 17], [17, 18], [18, 19], [19, 20], # Pinky
		[5, 9], [9, 13], [13, 17]            # Palm
	]

	# Convert normalized coordinates to screen coordinates
	var points: Array[Vector2] = []
	for lm in landmarks:
		var x: float = (1.0 - lm.get("x", 0.5)) * 1024  # Mirror horizontally
		var y: float = lm.get("y", 0.5) * 1024
		points.append(Vector2(x, y))

	# Draw connections
	for conn in connections:
		if conn[0] < points.size() and conn[1] < points.size():
			_hand_draw.draw_line(points[conn[0]], points[conn[1]], color, 3.0)

	# Draw landmarks as circles
	for point in points:
		_hand_draw.draw_circle(point, 8, color)


func _draw_progress_ring() -> void:
	if _current_progress <= 0:
		return

	var center := Vector2(100, 100)
	var radius := 80.0
	var start_angle := -PI / 2
	var end_angle := start_angle + (2 * PI * _current_progress)

	# Draw background ring
	_progress_ring.draw_arc(center, radius, 0, 2 * PI, 64, Color(1, 1, 1, 0.3), 8.0)

	# Draw progress arc
	var progress_color := Color(0.2, 1.0, 0.4) if _current_progress >= 1.0 else Color(1.0, 0.8, 0.2)
	_progress_ring.draw_arc(center, radius, start_angle, end_angle, 64, progress_color, 10.0)


func _unhandled_input(event: InputEvent) -> void:
	# Space or click to advance non-interactive panels
	var should_advance := false

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			should_advance = true
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			should_advance = true

	if should_advance:
		# Only allow manual advance for non-interactive panels
		if not is_waiting_for_interaction:
			_panel_timer.stop()
			_transition_to_next_panel()
			get_viewport().set_input_as_handled()


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
		GestureDetector.gesture_progress.connect(_on_gesture_progress)
		GestureDetector.landmarks_updated.connect(_on_landmarks_updated)


func _on_landmarks_updated(left_hand: Array, right_hand: Array) -> void:
	_left_landmarks = left_hand
	_right_landmarks = right_hand
	if _hand_draw:
		_hand_draw.queue_redraw()


func _on_gesture_progress(gesture_type: Enums.InteractionType, progress: float) -> void:
	if is_waiting_for_interaction and gesture_type == current_interaction_type:
		_current_progress = progress
		if _progress_ring:
			_progress_ring.visible = progress > 0
			_progress_ring.queue_redraw()


func load_panels(panel_data_array: Array[PanelData]) -> void:
	panels = panel_data_array
	_build_panel_strip()

	# Start first panel after building
	if panels.size() > 0:
		call_deferred("_start_panel", 0)


func _build_panel_strip() -> void:
	# Clear existing panels
	for child in panel_container.get_children():
		child.queue_free()

	var x_offset: float = 0.0

	# print("Building %d panels..." % panels.size())  # Debug
	for i in range(panels.size()):
		var panel_data := panels[i]
		var panel_node := _create_panel_node(panel_data, i)
		panel_node.position.x = x_offset
		panel_container.add_child(panel_node)
		# print("  Panel %d: x=%d, width=%d" % [i, int(x_offset), panel_data.panel_width])  # Debug
		x_offset += panel_data.panel_width


func _create_panel_node(panel_data: PanelData, index: int) -> Node2D:
	var panel_node := Node2D.new()
	panel_node.name = "Panel_%d" % index

	# Create background sprite
	var bg_sprite := Sprite2D.new()
	bg_sprite.name = "Background"
	bg_sprite.centered = false

	var is_placeholder := false
	if panel_data.background_path != "" and ResourceLoader.exists(panel_data.background_path):
		print("Loading background: ", panel_data.background_path)
		bg_sprite.texture = load(panel_data.background_path)
	else:
		# Create placeholder colored rectangle
		print("Background not found: ", panel_data.background_path, " - using placeholder")
		var placeholder := _create_placeholder_texture(panel_data.panel_width, 1024, index)
		bg_sprite.texture = placeholder
		is_placeholder = true

	panel_node.add_child(bg_sprite)

	# Add description label for placeholders
	if is_placeholder and panel_data.description != "":
		var label_container := Control.new()
		label_container.name = "LabelContainer"
		label_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		label_container.size = Vector2(panel_data.panel_width, 1024)

		var label := Label.new()
		label.name = "DescriptionLabel"
		label.text = panel_data.description
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_CENTER)
		label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		label.grow_vertical = Control.GROW_DIRECTION_BOTH
		label.custom_minimum_size = Vector2(panel_data.panel_width - 200, 400)
		label.add_theme_font_size_override("font_size", 48)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
		label.add_theme_constant_override("shadow_offset_x", 3)
		label.add_theme_constant_override("shadow_offset_y", 3)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		label_container.add_child(label)
		panel_node.add_child(label_container)

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
	# print("_start_panel(%d) called" % index)  # Debug

	if index < 0 or index >= panels.size():
		scene_completed.emit()
		return

	current_panel_index = index
	var panel_data := panels[index]

	panel_changed.emit(index)

	# Ensure camera is active and properly configured
	if camera:
		camera.make_current()
		camera.zoom = Vector2(1, 1)  # Ensure default zoom

	# Move camera to panel
	var target_x: float = _calculate_panel_camera_x(index)
	camera.position.x = target_x
	camera.position.y = 512  # Center vertically (1024/2)

	print("Panel %d" % index)  # Clean output

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

	# Tell gesture detector what gesture we're expecting
	if GestureDetector:
		GestureDetector.expected_gesture = panel_data.interaction_type

	interaction_required.emit(panel_data.interaction_type)

	# Show action UI with hint text
	var hint_text := panel_data.interaction_hint if panel_data.interaction_hint != "" else _get_default_hint(current_interaction_type)
	_show_action_text(hint_text)

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

	# Hide action UI and progress ring
	_hide_action_text()
	_current_progress = 0.0
	if _progress_ring:
		_progress_ring.visible = false

	# Play success effect
	_play_success_effect()

	interaction_completed.emit(current_interaction_type)

	is_waiting_for_interaction = false
	current_interaction_type = Enums.InteractionType.NONE

	# Wait for success effect before transitioning
	await get_tree().create_timer(0.5).timeout
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
		# Show hint label if it exists
		var hint_label = interaction_prompt.get_node_or_null("HintLabel")
		if hint_label:
			hint_label.text = panel_data.interaction_hint if panel_data.interaction_hint != "" else _get_default_hint(current_interaction_type)
			interaction_prompt.visible = true


func _get_default_hint(interaction_type: Enums.InteractionType) -> String:
	match interaction_type:
		Enums.InteractionType.CATCH:
			return "Show both open palms to catch"
		Enums.InteractionType.PASS:
			return "Show open palm to pass"
		Enums.InteractionType.BALLOON:
			return "Show open palm to pass the balloon"
		_:
			return ""


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


func _show_action_text(text: String) -> void:
	if _action_label and _action_bg:
		_action_label.text = text
		_action_bg.visible = true


func _hide_action_text() -> void:
	if _action_bg:
		_action_bg.visible = false


func _play_success_effect() -> void:
	if not _success_overlay:
		return

	# Flash white then fade out
	var tween := create_tween()
	tween.tween_property(_success_overlay, "color", Color(1, 1, 1, 0.6), 0.1)
	tween.tween_property(_success_overlay, "color", Color(0.4, 1, 0.4, 0.4), 0.15)
	tween.tween_property(_success_overlay, "color", Color(1, 1, 1, 0), 0.25)
