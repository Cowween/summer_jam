extends Node2D

@onready var bg_music: AudioStreamPlayer2D = $BgMusic
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var ui: AudioStreamPlayer2D = $UI

var tween : Tween
func play_bg(music: AudioStream) -> void:
	if music != bg_music.stream:
		if tween:
			tween.kill()
		bg_music.volume_db = 0.0
		bg_music.stream = music
		bg_music.play()
		
func play_sfx(sound: AudioStream) -> void:
	sfx.stream = sound
	sfx.play()
	
func play_ui(sound: AudioStream) -> void:
	ui.stream = sound
	ui.play()
	
func stop_ui() -> void:
	ui.stop()
	
func fade_out(duration: float = 30.0) -> void:
	# 1. Create a new tween
	tween = create_tween()
	
	# 2. Transition the volume_db property to -80 (silence) over the duration
	tween.tween_property(bg_music, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE)
	
	# 3. Automatically stop the audio player once the fade finishes
	tween.finished.connect(func(): bg_music.stop())
