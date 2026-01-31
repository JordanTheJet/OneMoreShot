@tool
class_name PanelData
extends Resource

## Resource class for configuring individual panels

## Unique identifier for this panel
@export var panel_id: String = ""

## Display duration in seconds (ignored if interaction required)
@export var duration: float = 3.0

## Type of interaction required to advance (NONE = auto-advance)
@export var interaction_type: Enums.InteractionType = Enums.InteractionType.NONE

## Path to the background image for this panel
@export_file("*.png", "*.jpg") var background_path: String = ""

## Optional foreground layers (parallax)
@export var foreground_layers: Array[String] = []

## Parallax depth values for foreground layers (0.0 = no movement, 1.0 = full movement)
@export var parallax_depths: Array[float] = []

## Camera focus point within the panel (normalized 0-1)
@export var focus_point: Vector2 = Vector2(0.5, 0.5)

## Panel width in pixels (for scrolling calculation)
@export var panel_width: int = 1920

## Transition type to next panel
@export var transition_to_next: Enums.TransitionType = Enums.TransitionType.PAN

## Custom transition duration (0 = use default)
@export var custom_transition_duration: float = 0.0

## Hint text to show if player doesn't interact
@export var interaction_hint: String = ""

## Time before showing hint (seconds)
@export var hint_delay: float = 5.0

## Fallback timeout if no interaction (seconds, 0 = no fallback)
@export var fallback_timeout: float = 15.0


func get_transition_duration() -> float:
	if custom_transition_duration > 0.0:
		return custom_transition_duration

	match transition_to_next:
		Enums.TransitionType.PAN:
			return 0.8
		Enums.TransitionType.DISSOLVE:
			return 1.2
		Enums.TransitionType.FADE_WHITE:
			return 1.5
		Enums.TransitionType.FADE_BLACK:
			return 1.0
		_:
			return 0.5
