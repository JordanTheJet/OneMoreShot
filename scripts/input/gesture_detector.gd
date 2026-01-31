extends Node

## Gesture recognition from hand landmark data

signal gesture_detected(gesture_type: Enums.InteractionType)
signal gesture_progress(gesture_type: Enums.InteractionType, progress: float)
signal hands_detected(count: int)

# Gesture thresholds
const CATCH_Y_THRESHOLD := 0.4  # Hands must be above this Y (0=top, 1=bottom)
const CATCH_HOLD_TIME := 0.3  # Seconds hands must be raised

const PASS_Z_FRAMES := 5  # Frames of forward motion required
const PASS_Z_VELOCITY_THRESHOLD := 0.02  # Z change per frame threshold

const BALLOON_Z_FRAMES := 8  # Frames of gentle forward motion
const BALLOON_Z_VELOCITY_MIN := 0.005  # Minimum velocity
const BALLOON_Z_VELOCITY_MAX := 0.015  # Maximum velocity (slower than pass)

var hand_tracking: HandTracking
var is_enabled: bool = true

# Tracking state
var _left_hand_history: Array[Dictionary] = []
var _right_hand_history: Array[Dictionary] = []
var _history_max_size: int = 30

# Catch gesture state
var _catch_start_time: float = 0.0
var _is_catching: bool = false

# Pass/Balloon gesture state
var _forward_motion_frames: int = 0


func _ready() -> void:
	# Create HandTracking instance
	hand_tracking = HandTracking.new()
	add_child(hand_tracking)

	hand_tracking.landmarks_received.connect(_on_landmarks_received)
	hand_tracking.tracking_lost.connect(_on_tracking_lost)
	hand_tracking.connection_status_changed.connect(_on_connection_changed)

	# Auto-connect to bridge
	call_deferred("_auto_connect")


func _auto_connect() -> void:
	hand_tracking.connect_to_bridge()


func _on_connection_changed(connected: bool) -> void:
	if connected:
		print("GestureDetector: Hand tracking connected")
	else:
		print("GestureDetector: Hand tracking disconnected")


func _on_tracking_lost() -> void:
	_reset_gesture_state()
	hands_detected.emit(0)


func _reset_gesture_state() -> void:
	_left_hand_history.clear()
	_right_hand_history.clear()
	_is_catching = false
	_catch_start_time = 0.0
	_forward_motion_frames = 0


func _on_landmarks_received(data: Dictionary) -> void:
	if not is_enabled:
		return

	var left_hand: Dictionary = data.get("left_hand", {})
	var right_hand: Dictionary = data.get("right_hand", {})

	var hand_count := 0
	if not left_hand.is_empty():
		hand_count += 1
	if not right_hand.is_empty():
		hand_count += 1

	hands_detected.emit(hand_count)

	# Update history
	_update_hand_history(left_hand, right_hand)

	# Check for gestures
	_check_catch_gesture(left_hand, right_hand)
	_check_forward_gestures(left_hand, right_hand)


func _update_hand_history(left: Dictionary, right: Dictionary) -> void:
	if not left.is_empty():
		_left_hand_history.push_back(left.duplicate())
		if _left_hand_history.size() > _history_max_size:
			_left_hand_history.pop_front()

	if not right.is_empty():
		_right_hand_history.push_back(right.duplicate())
		if _right_hand_history.size() > _history_max_size:
			_right_hand_history.pop_front()


func _check_catch_gesture(left: Dictionary, right: Dictionary) -> void:
	## Catch: Both hands raised above threshold, palms facing camera

	if left.is_empty() or right.is_empty():
		_is_catching = false
		return

	var left_wrist_y: float = _get_landmark_y(left, 0)  # Wrist
	var right_wrist_y: float = _get_landmark_y(right, 0)

	# Check if both hands are raised (lower Y = higher on screen)
	var both_raised := left_wrist_y < CATCH_Y_THRESHOLD and right_wrist_y < CATCH_Y_THRESHOLD

	if both_raised:
		if not _is_catching:
			_is_catching = true
			_catch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			var hold_time := Time.get_ticks_msec() / 1000.0 - _catch_start_time
			var progress := clampf(hold_time / CATCH_HOLD_TIME, 0.0, 1.0)
			gesture_progress.emit(Enums.InteractionType.CATCH, progress)

			if hold_time >= CATCH_HOLD_TIME:
				print("CATCH gesture detected!")
				gesture_detected.emit(Enums.InteractionType.CATCH)
				_reset_gesture_state()
	else:
		_is_catching = false


func _check_forward_gestures(left: Dictionary, right: Dictionary) -> void:
	## Pass: Palm pushes forward quickly
	## Balloon: Gentle forward motion (slower)

	# Use either hand for forward gestures
	var hand: Dictionary = right if not right.is_empty() else left
	if hand.is_empty():
		_forward_motion_frames = 0
		return

	var z_velocity := _calculate_z_velocity(hand)

	if z_velocity > PASS_Z_VELOCITY_THRESHOLD:
		_forward_motion_frames += 1

		if _forward_motion_frames >= PASS_Z_FRAMES:
			print("PASS gesture detected!")
			gesture_detected.emit(Enums.InteractionType.PASS)
			_reset_gesture_state()
		else:
			var progress := float(_forward_motion_frames) / PASS_Z_FRAMES
			gesture_progress.emit(Enums.InteractionType.PASS, progress)

	elif z_velocity > BALLOON_Z_VELOCITY_MIN and z_velocity < BALLOON_Z_VELOCITY_MAX:
		_forward_motion_frames += 1

		if _forward_motion_frames >= BALLOON_Z_FRAMES:
			print("BALLOON gesture detected!")
			gesture_detected.emit(Enums.InteractionType.BALLOON)
			_reset_gesture_state()
		else:
			var progress := float(_forward_motion_frames) / BALLOON_Z_FRAMES
			gesture_progress.emit(Enums.InteractionType.BALLOON, progress)
	else:
		# Reset if motion stops or reverses
		if _forward_motion_frames > 0:
			_forward_motion_frames = maxi(_forward_motion_frames - 2, 0)


func _get_landmark_y(hand: Dictionary, index: int) -> float:
	var landmarks: Array = hand.get("landmarks", [])
	if index < landmarks.size():
		return landmarks[index].get("y", 0.5)
	return 0.5


func _get_landmark_z(hand: Dictionary, index: int) -> float:
	var landmarks: Array = hand.get("landmarks", [])
	if index < landmarks.size():
		return landmarks[index].get("z", 0.0)
	return 0.0


func _calculate_z_velocity(hand: Dictionary) -> float:
	# Calculate forward motion velocity from palm center (landmark 9)
	var history: Array[Dictionary] = _right_hand_history if hand == _right_hand_history.back() else _left_hand_history

	if history.size() < 2:
		return 0.0

	var current_z := _get_landmark_z(hand, 9)  # Middle finger MCP
	var prev_hand: Dictionary = history[-2] if history.size() >= 2 else {}

	if prev_hand.is_empty():
		return 0.0

	var prev_z := _get_landmark_z(prev_hand, 9)

	# Positive velocity = moving toward camera (forward push)
	return prev_z - current_z


## Enable/disable gesture detection
func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	if not enabled:
		_reset_gesture_state()


## Get current tracking status
func get_status() -> String:
	return hand_tracking.get_status_string()


## Check if we're currently tracking hands
func is_tracking() -> bool:
	return hand_tracking.is_tracking
