extends AudioStreamPlayer

@export var _duration: float = 1
var _tween: Tween

func _ready() -> void:
	set_linear_volume(0)
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
func play_track(track: AudioStream, duration: float = _duration):
	if playing:
			if stream == track:
				return _fade_volume(File.settings.volume, duration)
			await _fade_volume(0, duration)
	self.stream = track
	self.play()
	return _fade_volume(File.settings.volume, duration)
	
	
func fade_out(duration: float = _duration):
	await _fade_volume(0, duration)
	stop()
	self.stream = null
	# return _tween.finished
	
func _fade_volume(target_volume: float, duration: float = _duration) -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(
		set_linear_volume,
		db_to_linear(self.volume_db),
		target_volume, duration
	)
	return _tween.finished
	
	
func set_linear_volume(linear_volume: float):
	self.volume_db = linear_to_db(linear_volume)
