extends AudioStreamPlayer


export(bool) var loop = true


func _on_Music_finished() -> void:
	if loop and Options.music:
		play()
