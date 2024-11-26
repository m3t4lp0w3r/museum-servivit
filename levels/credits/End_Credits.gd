extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	EventSystem.cutscene_started.emit()
	EventSystem.hide_hud.emit()
	$AnimationPlayer.play("credits")
	EventSystem.stop_sound.emit("Police_Siren_01")

func return_to_main_menu():
	LevelSystem.load_level("esterno_title")
