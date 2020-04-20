extends Control

signal countdown_complete

onready var days_count = $MarginContainer/CountdownContainer/DaysCount
onready var countdown_timer = $CountdownTimer

var countdown: int = 60 setget set_countdown


func _ready() -> void:
	days_count.text = str(countdown)


func set_countdown(value: int) -> void:
	countdown = value
	days_count.text = str(countdown)
	if countdown == 0:
		countdown_timer.stop()
		emit_signal("countdown_complete")


func _on_CountdownTimer_timeout() -> void:
	self.countdown -= 1
