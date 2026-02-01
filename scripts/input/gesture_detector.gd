extends Node

## Gesture recognition from hand landmark data
## Simplified MVP: Uses MediaPipe's built-in gesture recognition

signal gesture_detected(gesture_type: Enums.InteractionType)
signal gesture_progress(gesture_type: Enums.InteractionType, progress: float)
signal hands_detected(count: int)
signal landmarks_updated(left_hand: Array, right_hand: Array)

# Hold time for gesture confirmation
const GESTURE_HOLD_TIME := 0.5  # Seconds to hold gesture

var hand_tracking: HandTracking
var is_enabled: bool = true

# Current expected gesture (set by panel controller)
var expected_gesture: Enums.InteractionType = Enums.InteractionType.NONE

# Gesture timing state
var _gesture_start_time: float = 0.0
var _current_gesture_type: Enums.InteractionType = Enums.InteractionType.NONE


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
	_gesture_start_time = 0.0
	_current_gesture_type = Enums.InteractionType.NONE


func _on_landmarks_received(data: Dictionary) -> void:
	if not is_enabled:
		return

	var num_hands: int = data.get("num_hands", 0)
	hands_detected.emit(num_hands)

	# Extract landmark data for visualization
	var left_hand_data: Dictionary = data.get("left_hand", {})
	var right_hand_data: Dictionary = data.get("right_hand", {})
	var left_landmarks: Array = left_hand_data.get("landmarks", [])
	var right_landmarks: Array = right_hand_data.get("landmarks", [])
	landmarks_updated.emit(left_landmarks, right_landmarks)

	# Get gesture data from Python bridge
	var gestures: Dictionary = data.get("gestures", {})
	var left_gesture: String = gestures.get("left", "None")
	var right_gesture: String = gestures.get("right", "None")
	var two_open_palms: bool = data.get("two_open_palms", false)

	# Determine what gesture is being performed
	var detected_type := Enums.InteractionType.NONE

	# Check for any open palm
	var has_open_palm := left_gesture == "Open_Palm" or right_gesture == "Open_Palm"

	# CATCH: Two open palms
	if two_open_palms:
		detected_type = Enums.InteractionType.CATCH
	# PASS/BALLOON: Any open palm (one or two hands)
	# Use expected_gesture to determine which one to emit
	elif has_open_palm:
		if expected_gesture == Enums.InteractionType.BALLOON:
			detected_type = Enums.InteractionType.BALLOON
		else:
			detected_type = Enums.InteractionType.PASS

	# Check if gesture matches expected and track hold time
	if detected_type != Enums.InteractionType.NONE:
		if detected_type == _current_gesture_type:
			# Continue holding
			var hold_time := Time.get_ticks_msec() / 1000.0 - _gesture_start_time
			var progress := clampf(hold_time / GESTURE_HOLD_TIME, 0.0, 1.0)
			gesture_progress.emit(detected_type, progress)

			if hold_time >= GESTURE_HOLD_TIME:
				print("Gesture detected: ", Enums.InteractionType.keys()[detected_type])
				gesture_detected.emit(detected_type)
				_reset_gesture_state()
		else:
			# New gesture started
			_current_gesture_type = detected_type
			_gesture_start_time = Time.get_ticks_msec() / 1000.0
			gesture_progress.emit(detected_type, 0.0)
	else:
		# No valid gesture
		if _current_gesture_type != Enums.InteractionType.NONE:
			_reset_gesture_state()


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
