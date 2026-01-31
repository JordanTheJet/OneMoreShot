class_name Enums
extends RefCounted

## Shared enums for the game

enum InteractionType {
	NONE,       ## No interaction required, auto-advance
	CATCH,      ## Both hands rise up gesture
	PASS,       ## Palm pushes forward gesture
	BALLOON     ## Gentle forward motion gesture
}

enum TransitionType {
	NONE,           ## No transition
	PAN,            ## Pan between panels
	DISSOLVE,       ## Cross-dissolve between scenes
	FADE_WHITE,     ## Fade to white
	FADE_BLACK      ## Fade to black
}

enum GameState {
	INITIALIZING,
	PLAYING,
	PAUSED,
	TRANSITIONING,
	ENDED
}
