extends Control

signal resume

onready var music_button = $MenuOptions/MusicButton


func open_pause_menu():
	show()
	music_button.pressed = Options.music


func _on_ResumeButton_pressed() -> void:
	hide()
	emit_signal("resume")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_MusicButton_pressed() -> void:
	Options.music = music_button.pressed
	Signals.emit_signal("music_option_changed")
