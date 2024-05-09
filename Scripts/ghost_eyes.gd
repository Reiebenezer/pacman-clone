extends Sprite2D
class_name GhostEyes

@export_group("Eye Sprites")
@export var up: Texture2D
@export var down: Texture2D
@export var left: Texture2D
@export var right: Texture2D
@export_group("")

@onready var direction_table = {
	"down": down,
	"up": up,
	"left": left,
	"right": right
}

func _ready():
	(get_parent() as Ghost).direction_change.connect(on_direction_change)

func on_direction_change(direction: String):
	texture = direction_table[direction]

