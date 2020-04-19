extends TextureButton

export var crop_scene: PackedScene
onready var crop: Crop = crop_scene.instance()


func _ready() -> void:
	texture_normal.region = crop.get_atlas_region()
