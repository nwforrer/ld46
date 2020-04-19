extends Area2D


func _on_FlowerSeedBag_area_entered(area: Area2D) -> void:
	print('collide')


func _on_FlowerSeedBag_area_exited(area: Area2D) -> void:
	print('end collide')
