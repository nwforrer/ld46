extends Node2D
class_name Crop


export var dying_health: int = 3
export var young_health: int = 5
export var adult_health: int = 10
export var max_health: int = 15


onready var young_sprite = $YoungSprite
onready var adult_sprite = $AdultSprite
onready var dying_sprite = $DyingSprite


onready var current_health: int = young_health setget set_current_health
var hydration: float = 0 # percent


func _ready() -> void:
	change_life_stage()

func get_atlas_region() -> Texture:
	return $AdultSprite.region_rect


func water() -> void:
	hydration += 20
	hydration = clamp(hydration, 0.0, 100.0)


func change_life_stage():
	young_sprite.hide()
	adult_sprite.hide()
	dying_sprite.hide()
	if current_health >= adult_health:
		adult_sprite.show()
	elif current_health >= young_health:
		young_sprite.show()
	else:
		dying_sprite.show()


func set_current_health(value: int) -> void:
	current_health = value
	
	change_life_stage()
	
	if current_health <= 0:
		Signals.emit_signal("crop_died", global_position)
		queue_free()


func _on_LifeTimer_timeout() -> void:
	if hydration > 0:
		self.current_health += 1
	else:
		self.current_health -= 1
	self.current_health = clamp(current_health, 0.0, max_health)


func _on_WaterTimer_timeout() -> void:
	if hydration > 0:
		hydration -= 1
