extends Node2D

enum State {
	RUNNING,
	PAUSED,
	GAME_OVER
}

onready var music: AudioStreamPlayer = $Music
onready var plant_sound: AudioStreamPlayer = $PlantSound

onready var pause_menu: Control = $UI/PauseMenu
onready var game_over_menu: Control = $UI/GameOverScreen

onready var ground_tilemap: TileMap = $Ground
onready var crops: Node = $YSort/Crops

onready var player = $YSort/Player
onready var highlight = $HighlightSprite

onready var crop_scene: PackedScene = preload("res://world/Crop.tscn")

var current_state: int = State.RUNNING setget change_state

var crop_locations: Dictionary = {}


func _ready() -> void:
	if Options.music:
		music.play()
	Signals.connect("music_option_changed", self, "_on_music_option_changed")
	Signals.connect("tool_used", self, "_on_tool_used")
	Signals.connect("crop_died", self, "_on_crop_died")
	Signals.connect("crop_grown", self, "_on_crop_grown")
	Signals.connect("crop_dying", self, "_on_crop_dying")


func restart_game() -> void:
	get_tree().reload_current_scene()


func _process(delta: float) -> void:
	match current_state:
		State.RUNNING:
			running_state()
		State.PAUSED:
			paused_state()


func running_state():
	if Input.is_action_just_pressed("ui_cancel"):
		self.current_state = State.PAUSED
		
	if player.current_tool != null:
		var current_tool: Tool = player.current_tool
		var target_pos: Vector2 = current_tool.target_position.global_position
		var tool_tile_coords = ground_tilemap.world_to_map(target_pos)
		highlight.global_position = ground_tilemap.map_to_world(tool_tile_coords)
		highlight.show()
	else:
		highlight.hide()


func paused_state():
	if Input.is_action_just_pressed("ui_cancel"):
		self.current_state = State.RUNNING


func change_state(new_state: int) -> void:
	if new_state == current_state:
		return
	
	match new_state:
		State.PAUSED:
			pause_menu.open_pause_menu()
			get_tree().paused = true
		State.RUNNING:
			pause_menu.hide()
			get_tree().paused = false
	
	current_state = new_state


func _on_tool_used(tool_used: Tool, target_position: Vector2) -> void:
	var target_tile_coords = ground_tilemap.world_to_map(target_position)
	var target_crop: Crop = crop_locations.get(target_tile_coords)
	if tool_used as WateringCan:
		if target_crop != null:
			target_crop.water()
	elif tool_used as SeedBag:
		var seed_bag = tool_used as SeedBag
		if target_crop == null and seed_bag.crop != null:
			var placed_crop: Crop = seed_bag.crop.instance()
			placed_crop.global_position = ground_tilemap.map_to_world(target_tile_coords)
			crops.add_child(placed_crop)
			crop_locations[target_tile_coords] = placed_crop
			if Options.music:
				plant_sound.play()


func _on_crop_grown(crop: Crop) -> void:
	print('crop grown')


func _on_crop_dying(crop: Crop) -> void:
	print('crop dying')


func _on_crop_died(crop_location: Vector2) -> void:
	var tile_coords: Vector2 = ground_tilemap.world_to_map(crop_location)
	crop_locations.erase(tile_coords)


func _on_PauseMenu_resume() -> void:
	self.current_state = State.RUNNING


func _on_music_option_changed() -> void:
	if Options.music:
		music.play()
	else:
		music.stop()


func _on_HUD_countdown_complete() -> void:
	self.current_state = State.GAME_OVER
	var score: int = 0
	var adult_crop_count = 0
	var dead_crop_count = 0
	for crop in crops.get_children():
		var crop_state = (crop as Crop).current_life_stage
		if crop_state == Crop.LifeStage.ADULT:
			score += 1
			adult_crop_count += 1
		elif crop_state == Crop.LifeStage.DYING:
			score -= 1
			dead_crop_count += 1
	game_over_menu.game_over(score, adult_crop_count, dead_crop_count)
	get_tree().paused = true


func _on_GameOverScreen_play_again() -> void:
	restart_game()
