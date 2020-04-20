extends KinematicBody2D
class_name Player


enum State {
	IDLE,
	MOVING,
	WATERING
}


export var max_speed: float = 100.0
export var friction: float = 800.0
export var acceleration: float = 600.0

onready var tool_position = $ToolPosition
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

var current_state = State.IDLE setget _set_current_state
var velocity: Vector2
var facing_dir: Vector2 = Vector2.LEFT

var current_tool
var grabbable_tool


func _ready() -> void:
	animation_tree.active = true


func _process(delta: float) -> void:
	match current_state:
		State.IDLE, State.MOVING:
			default_state(delta)
		State.WATERING:
			watering_state(delta)
	
func watering_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move(Vector2.ZERO, delta)


func default_state(delta):
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
#	var mouse_dir = get_viewport().get_mouse_position() - global_position
#	facing_dir = mouse_dir.normalized()
	
	if input_vector != Vector2.ZERO:
		if facing_dir.x != 0 and input_vector.x == 0:
			facing_dir.y = input_vector.y
		else:
			facing_dir = input_vector
		self.current_state = State.MOVING
		animation_tree.set("parameters/Idle/blend_position", facing_dir)
		animation_tree.set("parameters/Run/blend_position", facing_dir)
		animation_state.travel("Run")
	else:
		self.current_state = State.IDLE
		animation_tree.set("parameters/Idle/blend_position", facing_dir)
		animation_state.travel("Idle")
	
	if Input.is_action_just_pressed("pickup_tool"):
		if grabbable_tool != null:
			if current_tool != null:
				current_tool.disconnect("finished_use",  self, "_on_finished_tool_use")
				current_tool.drop(get_parent(), grabbable_tool.global_position)
			grabbable_tool.pickup(tool_position, Vector2.ZERO)
			current_tool = grabbable_tool
			current_tool.connect("finished_use",  self, "_on_finished_tool_use")
			grabbable_tool = null
	
	move(input_vector, delta)
	
	if Input.is_action_just_pressed("use_tool"):
		if current_tool != null:
			var use_result: bool = current_tool.use()
			if use_result:
				self.current_state = State.WATERING


func move(input_vector: Vector2, delta: float) -> void:
	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * delta
		velocity = velocity.clamped(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _physics_process(delta: float) -> void:
	move_and_slide(velocity)


func _set_current_state(new_state: int) -> void:
	if new_state != current_state:
		current_state = new_state
		if new_state == State.WATERING:
			animation_state.travel("Idle")

func _on_finished_tool_use() -> void:
	self.current_state = State.IDLE


func _on_GrabArea_area_entered(area: Area2D) -> void:
	grabbable_tool = area


func _on_GrabArea_area_exited(area: Area2D) -> void:
	if area == grabbable_tool:
		grabbable_tool = null
