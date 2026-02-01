extends Node2D

## Scene 3: The Dining Room
## 4 panels, ends with BALLOON interaction
## Transition to Scene 4 is FADE_WHITE (representing loss/memory)

@onready var panel_controller: PanelController = $PanelController


func _ready() -> void:
	_setup_panels()


func _setup_panels() -> void:
	var panels: Array[PanelData] = []

	# Panel 1: Dining room - birthday setup
	var panel1 := PanelData.new()
	panel1.panel_id = "s3_p1_dining"
	panel1.background_path = "res://assets/sprites/scene3/panel1_table_wide/background.png"
	panel1.description = "SCENE 3 - THE DINING ROOM\n\nBirthday party setup.\nBalloons, decorations, cake on table.\nBut something feels different..."
	panel1.duration = 3.0
	panel1.interaction_type = Enums.InteractionType.NONE
	panel1.panel_width = 1024
	panel1.focus_point = Vector2(0.5, 0.5)
	panel1.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel1)

	# Panel 2: Mom's face
	var panel2 := PanelData.new()
	panel2.panel_id = "s3_p2_family"
	panel2.background_path = "res://assets/sprites/scene3/panel2_mom_face/background.png"
	panel2.description = "Family gathered around the table.\nMom trying to hold it together.\nMarcus, relatives. One chair empty."
	panel2.duration = 3.0
	panel2.interaction_type = Enums.InteractionType.NONE
	panel2.panel_width = 1024
	panel2.focus_point = Vector2(0.5, 0.5)
	panel2.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel2)

	# Panel 3: Jeffrey with balloon
	var panel3 := PanelData.new()
	panel3.panel_id = "s3_p3_absence"
	panel3.background_path = "res://assets/sprites/scene3/panel3_jeffrey_balloon/background.png"
	panel3.description = "Close-up: The empty chair.\nA framed photo of Jeffrey nearby.\nMom's hand resting near it."
	panel3.duration = 4.0
	panel3.interaction_type = Enums.InteractionType.NONE
	panel3.panel_width = 1024
	panel3.focus_point = Vector2(0.5, 0.5)
	panel3.transition_to_next = Enums.TransitionType.PAN
	panels.append(panel3)

	# Panel 4: Expression shift - BALLOON interaction
	var panel4 := PanelData.new()
	panel4.panel_id = "s3_p4_balloon"
	panel4.background_path = "res://assets/sprites/scene3/panel4_expression_shift/background.png"
	panel4.description = "A single balloon drifts toward the ceiling.\nPlayer's hand reaching up.\nLetting go...\n\n[BALLOON - Gentle push forward]"
	panel4.duration = 0.0  # Wait for interaction
	panel4.interaction_type = Enums.InteractionType.BALLOON
	panel4.panel_width = 1024
	panel4.focus_point = Vector2(0.5, 0.5)
	panel4.interaction_hint = "Gently push the balloon forward"
	panel4.hint_delay = 5.0
	panel4.fallback_timeout = 15.0
	panels.append(panel4)

	panel_controller.load_panels(panels)
