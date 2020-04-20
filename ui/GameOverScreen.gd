extends Control

signal play_again

onready var score_value = $Panel/VBoxContainer/HBoxContainer/ScoreValue
onready var harvest_count_text = $Panel/VBoxContainer/HarvestCount
onready var dead_count_text = $Panel/VBoxContainer/DeadCount


func game_over(score: int, adult_crop_count: int, dead_crop_count: int) -> void:
	score_value.text = str(score)
	harvest_count_text.text = "You harvested %d crops" % adult_crop_count
	dead_count_text.text = "You killed %d crops" % dead_crop_count
	show()


func _on_Button_pressed() -> void:
	get_tree().paused = false
	emit_signal("play_again")
