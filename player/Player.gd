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

var current_state = State.IDLE
var velocity: Vector2

var current_tool
var grabbable_tool


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
	
	if input_vector != Vector2.ZERO:
		current_state = State.MOVING
	else:
		current_state = State.IDLE
	
	if Input.is_action_just_pressed("pickup_tool"):
		if grabbable_tool != null:
			if current_tool != null:
				current_tool.disconnect("finished_use",  self, "_on_finished_tool_use")
			grabbable_tool.pickup(self, tool_position.position)
			current_tool = grabbable_tool
			current_tool.connect("finished_use",  self, "_on_finished_tool_use")
			grabbable_tool = null
	
	move(input_vector, delta)
	
	if Input.is_action_just_pressed("use_tool"):
		if current_tool != null:
			var use_result: bool = current_tool.use()
			current_state = State.WATERING


func move(input_vector: Vector2, delta: float) -> void:
	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * delta
		velocity = velocity.clamped(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _physics_process(delta: float) -> void:
	move_and_slide(velocity)


func _on_finished_tool_use() -> void:
	current_state = State.IDLE
	print('finished tool use')


func _on_GrabArea_area_entered(area: Area2D) -> void:
	grabbable_tool = area


func _on_GrabArea_area_exited(area: Area2D) -> void:
	if area == grabbable_tool:
		grabbable_tool = null
