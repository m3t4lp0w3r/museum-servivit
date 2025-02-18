extends Node2D

@export var dialog_1 : Array[DialogText]
@onready var animation_player = $CloseMuseumAnimation/AnimationPlayer
@onready var marker = $CloseMuseumAnimation/Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if TriggersSystem.check_trigger("night", true):
		$Giorno.hide()
		$Notte.show()
	
	if TriggersSystem.check_trigger("close_museum", true):
		animation_player.play("fade_out")
	
	EventSystem.play_music.emit("Traffic_01")
		
	TriggersSystem.toggle_trigger("from_exit")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	TriggersSystem.update_trigger("close_museum", false)
	TriggersSystem.update_trigger("act_3", true)
	DialogueSystem.start_dialog(dialog_1)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	%Player.position = marker.position
	EventSystem.set_volume.emit("Music", 0)
