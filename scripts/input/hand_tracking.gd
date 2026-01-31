class_name HandTracking
extends Node

## WebSocket client for receiving hand landmark data from Python MediaPipe bridge

signal connection_status_changed(connected: bool)
signal landmarks_received(data: Dictionary)
signal tracking_lost()
signal tracking_found()

const DEFAULT_HOST := "127.0.0.1"
const DEFAULT_PORT := 8765
const RECONNECT_DELAY := 2.0

var host: String = DEFAULT_HOST
var port: int = DEFAULT_PORT

var is_connected: bool = false
var is_tracking: bool = false

var _socket: WebSocketPeer
var _reconnect_timer: Timer
var _last_data_time: float = 0.0
var _tracking_timeout: float = 0.5  # Seconds without data before considering tracking lost


func _ready() -> void:
	_socket = WebSocketPeer.new()

	_reconnect_timer = Timer.new()
	_reconnect_timer.one_shot = true
	_reconnect_timer.timeout.connect(_attempt_connection)
	add_child(_reconnect_timer)


func _process(delta: float) -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			connection_status_changed.emit(false)
			_schedule_reconnect()
		return

	_socket.poll()

	match _socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not is_connected:
				is_connected = true
				connection_status_changed.emit(true)
				print("Hand tracking connected to ws://%s:%d" % [host, port])

			# Process incoming messages
			while _socket.get_available_packet_count() > 0:
				var packet := _socket.get_packet()
				_process_packet(packet)

		WebSocketPeer.STATE_CLOSING:
			pass  # Wait for close

		WebSocketPeer.STATE_CLOSED:
			pass  # Handled above

	# Check for tracking timeout
	if is_tracking and Time.get_ticks_msec() / 1000.0 - _last_data_time > _tracking_timeout:
		is_tracking = false
		tracking_lost.emit()


func connect_to_bridge(custom_host: String = "", custom_port: int = 0) -> void:
	if custom_host != "":
		host = custom_host
	if custom_port > 0:
		port = custom_port

	_attempt_connection()


func disconnect_from_bridge() -> void:
	_reconnect_timer.stop()
	if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_socket.close()
	is_connected = false
	is_tracking = false


func _attempt_connection() -> void:
	var url := "ws://%s:%d" % [host, port]
	print("Connecting to hand tracking at %s..." % url)

	var error := _socket.connect_to_url(url)
	if error != OK:
		push_warning("Failed to initiate WebSocket connection: %s" % error_string(error))
		_schedule_reconnect()


func _schedule_reconnect() -> void:
	if not _reconnect_timer.is_stopped():
		return
	_reconnect_timer.start(RECONNECT_DELAY)


func _process_packet(packet: PackedByteArray) -> void:
	var json_string := packet.get_string_from_utf8()
	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_warning("Failed to parse hand tracking JSON: %s" % json.get_error_message())
		return

	var data: Dictionary = json.data
	_last_data_time = Time.get_ticks_msec() / 1000.0

	if not is_tracking:
		is_tracking = true
		tracking_found.emit()

	landmarks_received.emit(data)


## Get the current connection status as a string
func get_status_string() -> String:
	if is_connected:
		if is_tracking:
			return "Connected - Tracking"
		else:
			return "Connected - No hands detected"
	else:
		return "Disconnected"
