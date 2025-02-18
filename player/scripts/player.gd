extends CharacterBody2D
class_name Player

@export var SPEED = 300.0
@export var interact_distance = 100

@onready var ray_cast = $RayCast2D
#@onready var sprite = $Sprite2D

var raycast_target : Vector2
var entered_interactable = null
var in_cutscene : bool = false
var in_shadow : bool = false

var direction : GameState.PLAYER_DIR
var schedule_phone_ring = false

func _ready() -> void:
	EventSystem.cutscene_started.connect(enter_cutscene)
	EventSystem.cutscene_finished.connect(exit_cutscene)
	
	EventSystem.all_task_completed.connect(all_task_completed)

func all_task_completed():
	if not in_cutscene:
		TriggersSystem.update_trigger("ring", true)
		schedule_phone_ring = false
	else:
		schedule_phone_ring = true

func enter_cutscene():
	in_cutscene = true
	ray_cast.enabled = false
	
func exit_cutscene():
	in_cutscene = false
	ray_cast.enabled = true

	#when the dialog of a patrol end, reset the room and trigger of allarm
	if TriggersSystem.check_trigger("allarm_ends", true):
		TriggersSystem.update_trigger("allarm_ends", false)
		TransictionScene.fade_out()
		LevelSystem.reload_current_level()

@onready var animation_tree: AnimationTree = $AnimationTree

var last_facing_dir := Vector2(0, 1)

@export_category("Audio")
@export var footstep : AudioStream

func _process(delta: float) -> void:
	if in_cutscene:
		animation_tree.set("parameters/conditions/idle", true)
		animation_tree.set("parameters/conditions/walk", false)
		return
	
	ray_cast.target_position = raycast_target	

	if ray_cast.is_colliding():
		var area_collider = ray_cast.get_collider()
		if area_collider != null and area_collider is Interactable:
			if entered_interactable == null:
				area_collider.player_enter_trigger()
				entered_interactable = area_collider
	else:
		if entered_interactable != null:
			entered_interactable.player_exit_trigger()
			entered_interactable = null
	
	if Input.is_action_just_pressed("interact") :
		if ray_cast.is_colliding():
			var area_collider = ray_cast.get_collider()
			if area_collider != null and area_collider is Interactable:
				area_collider.interact()
	
	if schedule_phone_ring and not in_cutscene:
		TriggersSystem.update_trigger("ring", true)
		schedule_phone_ring = false

func _physics_process(delta: float) -> void:

	if in_cutscene:
		animation_tree.set("parameters/conditions/idle", true)
		animation_tree.set("parameters/conditions/walk", false)
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_direction := Input.get_axis("left", "right")
	var y_direction := Input.get_axis("up", "down")
	
	#if x_direction > 0:
		#direction = GameState.PLAYER_DIR.RIGHT
	#if x_direction < 0:
		#direction = GameState.PLAYER_DIR.LEFT
	#if y_direction > 0:
		#direction = GameState.PLAYER_DIR.DOWN
	#if y_direction < 0:
		#direction = GameState.PLAYER_DIR.UP
		#
	#if x_direction > 0 and y_direction > 0:
		#direction = GameState.PLAYER_DIR.DOWN_RIGHT
	#if x_direction > 0 and y_direction < 0:
		#direction = GameState.PLAYER_DIR.UP_RIGHT
	#if x_direction < 0 and y_direction > 0:
		#direction = GameState.PLAYER_DIR.DOWN_LEFT
	#if x_direction < 0 and y_direction < 0:
		#direction = GameState.PLAYER_DIR.UP_LEFT
	
	#change_player_sprite()
	
	#if x_direction != 0 or y_direction != 0:
	
	#Animazione
	var idle = !velocity.normalized()
	
	if !idle:
		last_facing_dir = velocity.normalized()
	
	animation_tree.set("parameters/conditions/idle", idle)
	animation_tree.set("parameters/conditions/walk", !idle)
	
	animation_tree.set("parameters/Walk/blend_position", last_facing_dir)
	animation_tree.set("parameters/Idle/blend_position", last_facing_dir)
	
	#suono passi
	if velocity.length() != 0:
		if $Timer.time_left <= 0:
			AudioSystem.play(footstep) 
			$Timer.start()
	
	velocity = Vector2(x_direction, y_direction).normalized() * SPEED
	
	if x_direction != 0 or y_direction != 0 :
		raycast_target = Vector2(x_direction, y_direction).normalized() * interact_distance
		if $Camera2D.position_smoothing_enabled == false:
			%Player/Camera2D.position_smoothing_enabled = true
	
		
	velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

#TODO this needs to be changed based on the sprites and animations
#func change_player_sprite():
	#match direction:
		#GameState.PLAYER_DIR.RIGHT:
			#sprite.region_rect s= Rect2(0,32*2,32,32)
		#GameState.PLAYER_DIR.UP:
			#sprite.region_rect = Rect2(0,32*0,32,32)
		#GameState.PLAYER_DIR.DOWN:
			#sprite.region_rect = Rect2(0,32*4,32,32)
		#GameState.PLAYER_DIR.LEFT:
			#sprite.region_rect = Rect2(0,32*6,32,32)
		#GameState.PLAYER_DIR.DOWN_RIGHT:
			#sprite.region_rect = Rect2(0,32*3,32,32)
		#GameState.PLAYER_DIR.DOWN_LEFT:
			#sprite.region_rect = Rect2(0,32*5,32,32)
		#GameState.PLAYER_DIR.UP_RIGHT:
			#sprite.region_rect = Rect2(0,32*1,32,32)
		#GameState.PLAYER_DIR.UP_LEFT:
			#sprite.region_rect = Rect2(0,32*7,32,32)

func _on_portal_trigger_area_entered(area: Area2D) -> void:
	print("entered portal :", area.name)
	if area is Portal:
		var next_scene = area.level_id
		var next_link = area.link_id
		if next_scene != null and next_link != null:
			GameState.last_player_link_id = next_link
			LevelSystem.call_deferred("load_level", next_scene, true)
	
	if area is Shadow:
		in_shadow = true

func _on_portal_trigger_area_exited(area: Area2D) -> void:
	if area is Shadow:
		in_shadow = false
