extends "res://tools/Tool.gd"
class_name WateringCan

onready var animation_player = $AnimationPlayer
onready var water_sound = $WaterSound

var water_amount: float = 100 # perceent full


func use() -> bool:
	if animation_player.is_playing():
		return false

	if water_amount > 0:
		animation_player.play("use")
		#water_amount -= 10
		Signals.emit_signal("tool_used", self, target_position.global_position)
		return true
	return false


func _reparent(new_parent, hold_position):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = hold_position
	instruction_panel.hide()


func play_sound():
	if Options.music:
		water_sound.play()


func _on_finished_use():
	emit_signal("finished_use")
