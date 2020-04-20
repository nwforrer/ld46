extends Area2D
class_name Tool

signal finished_use

onready var instruction_panel = $InstructionPanel
onready var collision_shape = $CollisionShape2D
onready var shadow_sprite = $ShadowSprite
onready var target_position = $TargetPosition


func _ready() -> void:
	instruction_panel.hide()


func pickup(parent: Node2D, hold_position: Vector2) -> void:
	collision_shape.disabled = true
	shadow_sprite.hide()
	call_deferred("_reparent", parent, hold_position)


func drop(new_parent: Node2D, position: Vector2) -> void:
	collision_shape.disabled = false
	shadow_sprite.show()
	_reparent(new_parent, position)


func use() -> bool:
	return false


func _reparent(new_parent, hold_position):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = hold_position
	instruction_panel.hide()
	

func _on_finished_use():
	emit_signal("finished_use")


func _on_Tool_area_entered(area: Area2D) -> void:
	instruction_panel.show()


func _on_Tool_area_exited(area: Area2D) -> void:
	instruction_panel.hide()
