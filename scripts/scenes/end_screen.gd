extends Control

## End screen with "To Be Continued" and Play Again button

@onready var title: Label = $VBoxContainer/Title
@onready var subtitle: Label = $VBoxContainer/Subtitle
@onready var play_again_button: Button = $VBoxContainer/PlayAgainButton
@onready var fade_timer: Timer = $FadeTimer


func _ready() -> void:
	# Start with everything invisible
	modulate.a = 0.0
	play_again_button.visible = false

	# Connect signals
	fade_timer.timeout.connect(_on_fade_timer_timeout)
	play_again_button.pressed.connect(_on_play_again_pressed)

	# Start fade in after a brief delay
	await get_tree().create_timer(0.5).timeout
	_fade_in()


func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	await tween.finished

	# Show play again button after text is visible
	await get_tree().create_timer(1.0).timeout
	play_again_button.visible = true
	play_again_button.modulate.a = 0.0

	var button_tween := create_tween()
	button_tween.tween_property(play_again_button, "modulate:a", 1.0, 0.5)


func _on_fade_timer_timeout() -> void:
	pass  # Timer just for initial delay, handled in _ready


func _on_play_again_pressed() -> void:
	# Fade out and restart game
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished

	# Restart the game
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _input(event: InputEvent) -> void:
	# Also allow space/enter to restart
	if play_again_button.visible:
		if event.is_action_pressed("ui_accept"):
			_on_play_again_pressed()
