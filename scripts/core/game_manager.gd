extends Node

## Main game flow controller - manages scene sequencing and game state

signal game_state_changed(new_state: Enums.GameState)
signal scene_index_changed(scene_index: int)

const SCENE_ORDER: Array[String] = [
	"res://scenes/scene1_locker.tscn",
	"res://scenes/scene2_court.tscn",
	"res://scenes/scene3_dining.tscn",
	"res://scenes/scene4_championship.tscn",
]

const SCENE_TRANSITIONS: Array[Enums.TransitionType] = [
	Enums.TransitionType.DISSOLVE,      # 1 -> 2
	Enums.TransitionType.DISSOLVE,      # 2 -> 3
	Enums.TransitionType.FADE_WHITE,    # 3 -> 4
	Enums.TransitionType.FADE_BLACK,    # 4 -> end
]

var current_state: Enums.GameState = Enums.GameState.INITIALIZING
var current_scene_index: int = -1
var _current_panel_controller: PanelController = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	# Debug controls
	if OS.is_debug_build():
		if event.is_action_pressed("ui_accept"):  # Space/Enter
			_debug_advance()
		elif event.is_action_pressed("ui_cancel"):  # Escape
			_debug_skip_scene()


func start_game() -> void:
	print("Starting One More Shot...")
	_set_state(Enums.GameState.PLAYING)
	await _load_scene(0)


func _set_state(new_state: Enums.GameState) -> void:
	if current_state != new_state:
		current_state = new_state
		game_state_changed.emit(new_state)
		print("Game state: %s" % Enums.GameState.keys()[new_state])


func _load_scene(index: int) -> void:
	if index < 0 or index >= SCENE_ORDER.size():
		_end_game()
		return

	current_scene_index = index
	scene_index_changed.emit(index)

	var scene_path := SCENE_ORDER[index]

	if index == 0:
		# First scene - just change directly
		var error := get_tree().change_scene_to_file(scene_path)
		if error != OK:
			push_error("Failed to load first scene: %s" % scene_path)
			return
		await get_tree().process_frame
		_connect_to_panel_controller()
	else:
		# Use transition
		var transition_type := SCENE_TRANSITIONS[index - 1]
		_set_state(Enums.GameState.TRANSITIONING)
		await TransitionManager.transition_to_scene(scene_path, transition_type)
		_set_state(Enums.GameState.PLAYING)
		_connect_to_panel_controller()


func _connect_to_panel_controller() -> void:
	# Find PanelController in current scene
	await get_tree().process_frame

	var root := get_tree().current_scene
	if root == null:
		return

	_current_panel_controller = _find_panel_controller(root)

	if _current_panel_controller:
		if not _current_panel_controller.scene_completed.is_connected(_on_scene_completed):
			_current_panel_controller.scene_completed.connect(_on_scene_completed)
		print("Connected to PanelController in scene %d" % current_scene_index)
	else:
		push_warning("No PanelController found in scene")


func _find_panel_controller(node: Node) -> PanelController:
	if node is PanelController:
		return node

	for child in node.get_children():
		var result := _find_panel_controller(child)
		if result:
			return result

	return null


func _on_scene_completed() -> void:
	print("Scene %d completed" % current_scene_index)
	_current_panel_controller = null
	await _load_scene(current_scene_index + 1)


func _end_game() -> void:
	print("Game completed!")
	_set_state(Enums.GameState.ENDED)

	# Fade to black and stay
	await TransitionManager.fade_to_black(1.5)

	# Could show credits or return to title here
	await get_tree().create_timer(2.0).timeout

	# For now, quit or restart
	# get_tree().quit()


func _debug_advance() -> void:
	if _current_panel_controller:
		_current_panel_controller.debug_advance()


func _debug_skip_scene() -> void:
	print("Debug: Skipping to next scene")
	_on_scene_completed()


## Get current scene name for UI/debug
func get_current_scene_name() -> String:
	match current_scene_index:
		0: return "The Locker Room"
		1: return "The Court"
		2: return "The Dining Room"
		3: return "The Championship"
		_: return "Unknown"
