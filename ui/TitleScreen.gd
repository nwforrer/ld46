extends MarginContainer

onready var error_popup = $VBoxContainer/ErrorPopup
onready var error_label =  $VBoxContainer/ErrorPopup/Label
onready var music_check = $VBoxContainer/MenuOptions/MusicCheck


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
