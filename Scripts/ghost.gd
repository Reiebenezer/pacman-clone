extends Area2D
class_name Ghost

const ORIGINAL_SPEED = 120
const FRIGHTENED_SPEED = 50

@export var scatter_targets: Array[Node2D]
@export var at_home_targets: Array[Node2D]

@export var speed = ORIGINAL_SPEED
@export var tilemap: MazeTileMap
@export var player: Node2D
@export var body_color: Color

signal direction_change(direction: String)

enum GhostState {
	SCATTER,
	CHASE,
	FRIGHTENED,
	EATEN
}

var current_scatter_index = 0
var direction = null
var current_state: GhostState

@onready var body = $Body as GhostBody
@onready var eyes = $Eyes as GhostEyes

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var scatter_timer = $ScatterTimer
@onready var chase_interval = $ChaseInterval
@onready var frightened_timer = $FrightenedTimer
@onready var score = $Score

func _ready():
	call_deferred("setup")
	
func _process(delta):
	move_ghost(navigation_agent_2d.get_next_path_position(), delta)
	
func move_ghost(next_position: Vector2, delta: float):
	var current_ghost_pos = global_position
	var new_velocity = (next_position - current_ghost_pos).normalized() * speed * delta
	
	calculate_direction(new_velocity)
	
	position += new_velocity
	
func calculate_direction(velocity: Vector2):
	var current_direction
	
	if velocity.x > 1:
		current_direction = "right"
	elif velocity.x < -1:
		current_direction = "left"
	elif velocity.y > 1:
		current_direction = "down"
	elif velocity.y < -1:
		current_direction = "up"
		
	if current_direction != direction and current_direction != null:
		direction = current_direction
		direction_change.emit(direction)
	
func on_position_reached():
	match current_state:
		GhostState.SCATTER:
			current_scatter_index = 0 if current_scatter_index == 3 else current_scatter_index + 1
			navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position
		
		GhostState.CHASE:
			pass
			# print("Pacman is ded")
			
		GhostState.FRIGHTENED:
			navigation_agent_2d.target_position = tilemap.get_random_empty_cell()
	
	
func setup():
	navigation_agent_2d.set_navigation_map(tilemap.get_navigation_map(0))
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), tilemap.get_navigation_map(0))
	
	scatter()

func scatter():
	scatter_timer.start()
	current_state = GhostState.SCATTER
	navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position

func _on_scatter_timeout():
	if current_state != GhostState.FRIGHTENED:
		chase()

func chase():
	current_state = GhostState.CHASE
	
	if player == null:
		print("No target. Chasing will not work")
	
	chase_interval.start()
	navigation_agent_2d.target_position = player.position

func _on_chase_interval_timeout():
	navigation_agent_2d.target_position = player.position

func frighten():
	current_state = GhostState.FRIGHTENED
	
	eyes.hide()
	body.frighten()
	frightened_timer.start()
		
	chase_interval.stop()
	
	navigation_agent_2d.target_position = tilemap.get_random_empty_cell()
	speed = FRIGHTENED_SPEED
	
func _on_frightened_timer_timeout():
	if body.is_playing("frightened"):
		frightened_timer.start()
		body.frighten_conclude()
		
	else:
		body.move()
		eyes.show()
		
		scatter()
		
		speed = ORIGINAL_SPEED


func _on_body_entered(collision_body):
	if not collision_body is Player:
		return
		
	var _player = collision_body as Player
	
	if current_state == GhostState.FRIGHTENED:
		get_eaten()
		pass
		
	else:
		chase_interval.stop()
		_player.died()
		scatter()

func get_eaten():
	body.hide()
	eyes.show()
	
	score.text = str(Manager.ghost_score_increment)
	score.show()
	
	await Manager.score_ghost()
	score.hide()
	
	frightened_timer.stop()
	current_state = GhostState.EATEN
