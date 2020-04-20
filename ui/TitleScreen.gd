extends Control

onready var error_popup = $MarginContainer/VBoxContainer/ErrorPopup
onready var error_label =  $MarginContainer/VBoxContainer/ErrorPopup/Label
onready var music_check = $MarginContainer/VBoxContainer/HBoxContainer/MenuOptions/MusicCheck


func _ready() -> void:
	Options.music = music_check.pressed


func _on_StartButton_pressed() -> void:
	var result: int = get_tree().change_scene("res://Main.tscn")
	match result:
		ERR_CANT_CREATE, ERR_CANT_OPEN:
			error_label.text = "Failed to load main scene!"
			error_popup.popup()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_MusicCheck_pressed() -> void:
	Options.music = music_check.pressed


func _on_TutorialButton_pressed() -> void:
	get_tree().change_scene("res://Tutorial.tscn")
