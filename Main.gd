extends Node2D

enum State {
	RUNNING,
	PLACING_CROP,
	PAUSED
}

onready var music: AudioStreamPlayer = $Music
onready var pause_menu: Control = $UI/PauseMenu
onready var crop_selection_grid: GridContainer = $UI/CropSelection/CropGrid
onready var ground_tilemap: TileMap = $Ground
onready var crops: Node = $Crops

onready var crop_scene: PackedScene = preload("res://world/Crop.tscn")

var current_state: int = State.RUNNING setget change_state

var attached_crop: Sprite = Sprite.new()
var selected_crop: Crop

var crop_locations: Dictionary = {}


func _ready() -> void:
	if Options.music:
		music.play()
	Signals.connect("music_option_changed", self, "_on_music_option_changed")
	Signals.connect("tool_used", self, "_on_tool_used")
	Signals.connect("crop_died", self, "_on_crop_died")
				
	add_child(attached_crop)
	attached_crop.hide()
	for crop_item in crop_selection_grid.get_children():
		crop_item = crop_item as TextureButton
		crop_item.connect("pressed", self, "_on_crop_selected", [crop_item.texture_normal, crop_item.crop])


func _on_crop_selected(crop_item_texture: Texture, crop: Crop) -> void:
	if current_state == State.PAUSED:
		return
	
	selected_crop = crop
	attached_crop.show()
	attached_crop.texture = crop_item_texture
	attached_crop.centered = false
	var mouse_coords: Vector2 = get_viewport().get_mouse_position()
	var tile_coords: Vector2 = ground_tilemap.world_to_map(mouse_coords)
	attached_crop.global_position = ground_tilemap.map_to_world(tile_coords)
	self.current_state = State.PLACING_CROP


func _process(delta: float) -> void:
	match current_state:
		State.RUNNING:
			running_state()
		State.PAUSED:
			paused_state()
		State.PLACING_CROP:
			placing_crop_state()


func placing_crop_state():
	var mouse_coords: Vector2 = get_viewport().get_mouse_position()
	var tile_coords: Vector2 = ground_tilemap.world_to_map(mouse_coords)
	attached_crop.global_position = ground_tilemap.map_to_world(tile_coords)
	
	if Input.is_action_just_pressed("place_crop"):
		var placed_crop: Crop = selected_crop.duplicate()
		placed_crop.global_position = attached_crop.global_position
		crops.add_child(placed_crop)
		crop_locations[ground_tilemap.world_to_map(placed_crop.global_position)] = placed_crop
	elif Input.is_action_just_pressed("stop_placing"):
		attached_crop.hide()
		selected_crop = null
		self.current_state = State.RUNNING


func running_state():
	if Input.is_action_just_pressed("ui_cancel"):
		self.current_state = State.PAUSED


func paused_state():
	if Input.is_action_just_pressed("ui_cancel"):
		self.current_state = State.RUNNING


func change_state(new_state: int) -> void:
	if new_state == current_state:
		return
	
	match new_state:
		State.PAUSED:
			pause_menu.open_pause_menu()
		State.RUNNING:
			pause_menu.hide()
	
	current_state = new_state


func _on_tool_used(target_position: Vector2) -> void:
	var target_tile_coords = ground_tilemap.world_to_map(target_position)
	var target_crop: Crop = crop_locations.get(target_tile_coords)
	if target_crop != null:
		target_crop.water()


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
