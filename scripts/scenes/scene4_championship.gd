extends Node2D

## Scene 4: The Championship
## 3 panels, no interaction - emotional conclusion
## Auto-plays to completion, then fades to black

@onready var panel_controller: PanelController = $PanelController


func _ready() -> void:
	_setup_panels()


func _setup_panels() -> void:
	var panels: Array[PanelData] = []

	# Panel 1: Championship game - wide arena shot
	var panel1 := PanelData.new()
	panel1.panel_id = "s4_p1_arena"
	panel1.duration = 4.0
	panel1.interaction_type = Enums.InteractionType.NONE
	panel1.panel_width = 1920
	panel1.focus_point = Vector2(0.5, 0.5)
	panel1.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel1)

	# Panel 2: The final shot moment
	var panel2 := PanelData.new()
	panel2.panel_id = "s4_p2_shot"
	panel2.duration = 4.5
	panel2.interaction_type = Enums.InteractionType.NONE
	panel2.panel_width = 1920
	panel2.focus_point = Vector2(0.5, 0.5)
	panel2.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel2)

	# Panel 3: Resolution - looking up, remembering
	var panel3 := PanelData.new()
	panel3.panel_id = "s4_p3_resolution"
	panel3.duration = 5.0
	panel3.interaction_type = Enums.InteractionType.NONE
	panel3.panel_width = 1920
	panel3.focus_point = Vector2(0.5, 0.5)
	panel3.transition_to_next = Enums.TransitionType.FADE_BLACK
	panels.append(panel3)

	panel_controller.load_panels(panels)
