extends StageManager
@onready var ending: Interactable = $Triggers/Ending
@onready var god: StaticBody2D = $Anomalies/God
@onready var cg: CanvasLayer = $CG
@onready var fade_out_white: ColorRect = $CG/FadeOutWhite
@onready var texture_rect: TextureRect = $CG/TextureRect
const DEEZNATSU_BOSSLOOP = preload("uid://5ch1iwpd4vty")
const DEEZNATSU_EPILOGUE = preload("uid://dumgbbguoggo0")


func _ready() -> void:
	super()
	DialogueManager.show_dialogue_balloon(stage_script, "start")
	ending.monitorable = false
	ending.hide()
	GameBus.show_cg.connect(_show_cg)
	SoundManager.bg_music.finished.connect(_music_finished)
func _on_god_boss_die() -> void:
	SoundManager.fade_out()
	DialogueManager.show_dialogue_balloon(stage_script, "boss_die")
	await DialogueManager.dialogue_ended
	var tween := create_tween()
	SoundManager.play_bg(DEEZNATSU_EPILOGUE)
	tween.tween_property(fade_out_white, "color:a", 1.0, 2.0)
	await get_tree().create_timer(2.0).timeout
	god.die()
	DialogueManager.show_dialogue_balloon(stage_script, "ending")

	
func _show_cg() -> void:
	texture_rect.show()
	var tween := create_tween()
	tween.tween_property(fade_out_white, "color:a", 0.0, 2.0)
	
func _music_finished() -> void:
	SoundManager.play_bg(DEEZNATSU_BOSSLOOP)

func _on_ending_interacted() -> void:
	DialogueManager.show_dialogue_balloon(stage_script, "ending")
