extends "res://tools/Tool.gd"
class_name SeedBag

export var crop: PackedScene


func use() -> bool:
	Signals.emit_signal("tool_used", self, target_position.global_position)
	call_deferred("emit_signal", "finished_use")
	return true
	
