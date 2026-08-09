extends Node

## Lightweight SFX + looping BGM.

const SFX_DIR := "res://shared/audio/sfx/"
const TI_THEME := "res://games/treasure-island/audio/theme.wav"

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	_sfx_player.bus = "Master"
	add_child(_sfx_player)
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	add_child(_music_player)


func play_sfx(sfx_id: String, volume_db: float = 0.0) -> void:
	if sfx_id.is_empty() or _sfx_player == null:
		return
	var stream := _get_sfx(sfx_id)
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.volume_db = volume_db
	_sfx_player.play()


func play_music(path: String = TI_THEME, volume_db: float = -8.0) -> void:
	if _music_player == null:
		return
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	if _music_player.playing and _music_player.stream == stream:
		return
	_music_player.stream = stream
	_music_player.volume_db = volume_db
	_music_player.play()


func stop_music() -> void:
	if _music_player == null:
		return
	if _music_player.playing:
		_music_player.stop()
	_music_player.stream = null


func _get_sfx(sfx_id: String) -> AudioStream:
	if _sfx_cache.has(sfx_id):
		return _sfx_cache[sfx_id]
	var path := SFX_DIR.path_join("%s.wav" % sfx_id)
	if not ResourceLoader.exists(path):
		return null
	var stream: AudioStream = load(path)
	_sfx_cache[sfx_id] = stream
	return stream
