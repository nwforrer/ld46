extends "res://tools/Tool.gd"

onready var animation_player = $AnimationPlayer
onready var target_position = $TargetPosition

var water_amount: float = 100 # perceent full


func use() -> bool:
	if animation_player.is_playing():
		return false

	if water_amount > 0:
		animation_player.play("use")
		water_amount -= 10
		Signals.emit_signal("tool_used", target_position.global_position)
		return true
	return false


func _reparent(new_parent, hold_position):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = hold_position
	instruction_panel.hide()


func _on_finished_use():
	emit_signal("finished_use")


func _on_WateringCan_area_entered(_area: Area2D) -> void:
	instruction_panel.show()


func _on_WateringCan_area_exited(_area: Area2D) -> void:
	instruction_panel.hide()


func _on_TestTool_area_entered(area: Area2D) -> void:
	instruction_panel.show()


func _on_TestTool_area_exited(area: Area2D) -> void:
	instruction_panel.hide()
