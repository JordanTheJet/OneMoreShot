extends Node2D

## Scene 2: The Court
## 5 panels, ends with PASS interaction

@onready var panel_controller: PanelController = $PanelController


func _ready() -> void:
	_setup_panels()


func _setup_panels() -> void:
	var panels: Array[PanelData] = []

	# Panel 1: Wide shot - basketball court
	var panel1 := PanelData.new()
	panel1.panel_id = "s2_p1_court_wide"
	panel1.background_path = "res://assets/sprites/scene2/panel1_court_wide/background.png"
	panel1.description = "SCENE 2 - THE COURT\n\nWide shot: Boston outdoor basketball court.\nGolden hour lighting, long shadows.\nJeffrey and young Marcus visible in distance."
	panel1.duration = 3.0
	panel1.interaction_type = Enums.InteractionType.NONE
	panel1.panel_width = 1024
	panel1.focus_point = Vector2(0.5, 0.5)
	panel1.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel1)

	# Panel 2: Jeffrey catching breath
	var panel2 := PanelData.new()
	panel2.panel_id = "s2_p2_coaching"
	panel2.background_path = "res://assets/sprites/scene2/panel2_jeffrey_rest/background.png"
	panel2.description = "Jeffrey demonstrating shooting form.\nHands guiding Marcus's arms.\nPatient, encouraging big brother."
	panel2.duration = 3.0
	panel2.interaction_type = Enums.InteractionType.NONE
	panel2.panel_width = 1024
	panel2.focus_point = Vector2(0.5, 0.5)
	panel2.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel2)

	# Panel 3: Jeffrey grins
	var panel3 := PanelData.new()
	panel3.panel_id = "s2_p3_practice"
	panel3.background_path = "res://assets/sprites/scene2/panel3_jeffrey_grin/background.png"
	panel3.description = "Multiple exposure style: Practice moments.\nDribbling, shooting, high-fives.\nJoy of learning together."
	panel3.duration = 2.5
	panel3.interaction_type = Enums.InteractionType.NONE
	panel3.panel_width = 1024
	panel3.focus_point = Vector2(0.5, 0.5)
	panel3.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel3)

	# Panel 4: Jeffrey ready position
	var panel4 := PanelData.new()
	panel4.panel_id = "s2_p4_connection"
	panel4.background_path = "res://assets/sprites/scene2/panel4_jeffrey_ready/background.png"
	panel4.description = "Jeffrey and Marcus sitting on court, resting.\nSharing a water bottle.\nSun setting behind them. Brothers."
	panel4.duration = 3.5
	panel4.interaction_type = Enums.InteractionType.NONE
	panel4.panel_width = 1024
	panel4.focus_point = Vector2(0.5, 0.5)
	panel4.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel4)

	# Panel 5: Pass the ball - PASS interaction
	var panel5 := PanelData.new()
	panel5.panel_id = "s2_p5_pass"
	panel5.background_path = "res://assets/sprites/scene2/panel5_jeffrey_shot/background.png"
	panel5.description = "Jeffrey ready to receive a pass.\nArms open, encouraging smile.\nWaiting for the ball.\n\n[PASS - Push forward]"
	panel5.duration = 0.0  # Wait for interaction
	panel5.interaction_type = Enums.InteractionType.PASS
	panel5.panel_width = 1024
	panel5.focus_point = Vector2(0.5, 0.5)
	panel5.interaction_hint = "Push forward to pass"
	panel5.hint_delay = 5.0
	panel5.fallback_timeout = 15.0
	panels.append(panel5)

	panel_controller.load_panels(panels)
