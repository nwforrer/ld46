extends Node2D
class_name Crop

enum State {
	GROWING,
	ADULT,
	DEAD
}

enum LifeStage {
	YOUNG,
	GROWING,
	ADULT,
	DYING
}

export var young_health: int = 3
export var growing_health: int = 5
export var adult_health: int = 10
export var max_health: int = 10


onready var young_sprite = $YoungSprite
onready var growing_sprite = $GrowingSprite
onready var adult_sprite = $AdultSprite
onready var dying_sprite = $DyingSprite


onready var current_health: int = young_health setget set_current_health
var hydration: float = 0 # percent

var current_life_stage = LifeStage.YOUNG setget set_life_stage
var current_state = State.GROWING


func _ready() -> void:
	young_sprite.show()
	change_life_stage()

func get_atlas_region() -> Texture:
	return $AdultSprite.region_rect


func water() -> void:
	hydration += 20
	hydration = clamp(hydration, 0.0, 100.0)


func change_life_stage():
	match current_state:
		State.GROWING:
			if current_health >= adult_health:
				self.current_life_stage = LifeStage.ADULT
			elif current_health >= growing_health:
				self.current_life_stage = LifeStage.GROWING
			elif current_health >= young_health:
				self.current_life_stage = LifeStage.YOUNG
		State.ADULT:
			if current_health == 0:
				self.current_life_stage = LifeStage.DYING


func set_life_stage(value: int) -> void:
	if value != current_life_stage:
		young_sprite.hide()
		growing_sprite.hide()
		adult_sprite.hide()
		dying_sprite.hide()
		
		if current_life_stage == LifeStage.ADULT:
			Signals.emit_signal("crop_dying", self)
		
		match value:
			LifeStage.YOUNG:
				young_sprite.show()
			LifeStage.GROWING:
				growing_sprite.show()
			LifeStage.ADULT:
				adult_sprite.show()
				current_state = State.ADULT
				Signals.emit_signal("crop_grown", self)
			LifeStage.DYING:
				current_state = State.DEAD
				dying_sprite.show()
		
		current_life_stage = value


func set_current_health(value: int) -> void:
	current_health = value
	
	change_life_stage()
	
	if current_health <= 0:
		Signals.emit_signal("crop_died", global_position)


func _on_LifeTimer_timeout() -> void:
	match current_state:
		State.GROWING:
			if hydration > 0:
				self.current_health += 1
		State.ADULT:
			if hydration == 0:
				self.current_health -= 1
	self.current_health = clamp(current_health, 0.0, max_health)


func _on_WaterTimer_timeout() -> void:
	if hydration > 0:
		hydration -= 1
