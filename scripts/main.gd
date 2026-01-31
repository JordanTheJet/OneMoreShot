extends Node

## Main scene entry point - initializes game systems and starts gameplay

@onready var start_delay: Timer = $StartDelay


func _ready() -> void:
	print("=== One More Shot ===")
	print("Initializing game systems...")

	# Wait for autoloads to be ready
	await get_tree().process_frame

	# Show connection status
	if GestureDetector:
		print("Gesture detection: %s" % GestureDetector.get_status())

	# Connect start delay
	start_delay.timeout.connect(_on_start_delay_timeout)


func _on_start_delay_timeout() -> void:
	print("Starting game...")
	GameManager.start_game()


func _input(event: InputEvent) -> void:
	# Debug: R to restart game
	if OS.is_debug_build() and event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			print("Restarting game...")
			get_tree().reload_current_scene()
