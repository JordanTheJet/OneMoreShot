extends Node2D

## Scene 1: The Locker Room
## 4 panels, ends with CATCH interaction

@onready var panel_controller: PanelController = $PanelController


func _ready() -> void:
	_setup_panels()


func _setup_panels() -> void:
	var panels: Array[PanelData] = []

	# Panel 1: Wide shot - locker room establishing
	var panel1 := PanelData.new()
	panel1.panel_id = "s1_p1_establishing"
	panel1.duration = 3.5
	panel1.interaction_type = Enums.InteractionType.NONE
	panel1.panel_width = 1920
	panel1.focus_point = Vector2(0.5, 0.5)
	panel1.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel1)

	# Panel 2: Father figure in doorway
	var panel2 := PanelData.new()
	panel2.panel_id = "s1_p2_father"
	panel2.duration = 3.0
	panel2.interaction_type = Enums.InteractionType.NONE
	panel2.panel_width = 1920
	panel2.focus_point = Vector2(0.5, 0.5)
	panel2.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel2)

	# Panel 3: Close-up of character's face
	var panel3 := PanelData.new()
	panel3.panel_id = "s1_p3_closeup"
	panel3.duration = 2.5
	panel3.interaction_type = Enums.InteractionType.NONE
	panel3.panel_width = 1920
	panel3.focus_point = Vector2(0.5, 0.5)
	panel3.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel3)

	# Panel 4: Ball being tossed - CATCH interaction
	var panel4 := PanelData.new()
	panel4.panel_id = "s1_p4_catch"
	panel4.duration = 0.0  # Wait for interaction
	panel4.interaction_type = Enums.InteractionType.CATCH
	panel4.panel_width = 1920
	panel4.focus_point = Vector2(0.5, 0.5)
	panel4.interaction_hint = "Raise both hands to catch the ball"
	panel4.hint_delay = 5.0
	panel4.fallback_timeout = 15.0
	panels.append(panel4)

	panel_controller.load_panels(panels)
