extends Sprite2D
class_name GhostBody

@onready var animation_player = $"../AnimationPlayer" as AnimationPlayer

func _ready():
	move()
	
func move():
	revert_color()
	animation_player.play("moving")
	
func frighten():
	self.modulate = Color.WHITE
	animation_player.play("frightened")

func frighten_conclude():
	animation_player.play("frightened_ending")

func is_playing(state: String) -> bool:
	return animation_player.current_animation == state

func update_color(color: Color):
	self.modulate = color
	
func revert_color():
	self.modulate = (get_parent() as Ghost).body_color
