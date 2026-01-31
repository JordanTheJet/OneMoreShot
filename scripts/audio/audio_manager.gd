extends Node

## Manages music and sound effect playback with crossfade support

signal music_changed(track_name: String)

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

const DEFAULT_CROSSFADE_DURATION := 2.0
const DEFAULT_MUSIC_VOLUME := -6.0  # dB
const DEFAULT_SFX_VOLUME := 0.0  # dB

var current_music_track: String = ""
var music_volume: float = DEFAULT_MUSIC_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _max_sfx_players: int = 8


func _ready() -> void:
	_setup_audio_buses()
	_setup_music_players()
	_setup_sfx_pool()


func _setup_audio_buses() -> void:
	# Ensure Music and SFX buses exist
	var music_bus_idx := AudioServer.get_bus_index(MUSIC_BUS)
	if music_bus_idx == -1:
		# Bus doesn't exist in default layout, use Master
		push_warning("Music bus not found, using Master")

	var sfx_bus_idx := AudioServer.get_bus_index(SFX_BUS)
	if sfx_bus_idx == -1:
		push_warning("SFX bus not found, using Master")


func _setup_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = MUSIC_BUS if AudioServer.get_bus_index(MUSIC_BUS) != -1 else "Master"
	_music_player_a.volume_db = music_volume
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = MUSIC_BUS if AudioServer.get_bus_index(MUSIC_BUS) != -1 else "Master"
	_music_player_b.volume_db = -80.0  # Start silent
	add_child(_music_player_b)

	_active_player = _music_player_a


func _setup_sfx_pool() -> void:
	for i in range(_max_sfx_players):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS if AudioServer.get_bus_index(SFX_BUS) != -1 else "Master"
		player.volume_db = sfx_volume
		add_child(player)
		_sfx_players.append(player)


## Play music with optional crossfade
func play_music(stream: AudioStream, crossfade: bool = true, crossfade_duration: float = DEFAULT_CROSSFADE_DURATION) -> void:
	if stream == null:
		push_warning("Attempted to play null music stream")
		return

	var track_name := stream.resource_path.get_file()

	if track_name == current_music_track and _active_player.playing:
		return  # Already playing this track

	current_music_track = track_name
	music_changed.emit(track_name)

	var inactive_player := _music_player_b if _active_player == _music_player_a else _music_player_a

	inactive_player.stream = stream
	inactive_player.volume_db = -80.0 if crossfade else music_volume
	inactive_player.play()

	if crossfade and _active_player.playing:
		await _crossfade(inactive_player, _active_player, crossfade_duration)
	else:
		inactive_player.volume_db = music_volume
		_active_player.stop()

	_active_player = inactive_player


## Stop music with optional fade out
func stop_music(fade_duration: float = 1.0) -> void:
	if not _active_player.playing:
		return

	current_music_track = ""

	if fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_active_player, "volume_db", -80.0, fade_duration)
		await tween.finished

	_active_player.stop()
	_active_player.volume_db = music_volume


## Play a sound effect
func play_sfx(stream: AudioStream, volume_offset: float = 0.0, pitch_variation: float = 0.0) -> void:
	if stream == null:
		return

	var player := _get_available_sfx_player()
	if player == null:
		push_warning("No available SFX players")
		return

	player.stream = stream
	player.volume_db = sfx_volume + volume_offset

	if pitch_variation > 0:
		player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	else:
		player.pitch_scale = 1.0

	player.play()


## Play sound at specific position (for 2D spatial audio)
func play_sfx_at_position(stream: AudioStream, position: Vector2, volume_offset: float = 0.0) -> void:
	# For this project, we'll just play normally since it's a narrative game
	# Could be extended with AudioStreamPlayer2D for spatial audio
	play_sfx(stream, volume_offset)


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player

	# All players busy, return the one that started earliest
	# (Simple approach - could track start times for better selection)
	return _sfx_players[0]


func _crossfade(fade_in: AudioStreamPlayer, fade_out: AudioStreamPlayer, duration: float) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(fade_in, "volume_db", music_volume, duration)
	tween.tween_property(fade_out, "volume_db", -80.0, duration)
	await tween.finished

	fade_out.stop()


## Set music volume (dB)
func set_music_volume(volume_db: float) -> void:
	music_volume = volume_db
	if _active_player.playing:
		_active_player.volume_db = volume_db


## Set SFX volume (dB)
func set_sfx_volume(volume_db: float) -> void:
	sfx_volume = volume_db
	for player in _sfx_players:
		player.volume_db = volume_db


## Get music volume (dB)
func get_music_volume() -> float:
	return music_volume


## Get SFX volume (dB)
func get_sfx_volume() -> float:
	return sfx_volume


## Check if music is currently playing
func is_music_playing() -> bool:
	return _active_player.playing
