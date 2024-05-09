extends Area2D
class_name Ghost

signal direction_change(direction: String)

@export var scatter_targets: Array[Marker2D]
@export var at_home_targets: Array[Marker2D]

@export var tilemap: MazeTileMap
@export var player: Player
@export var body_color: Color

@export var ORIGINAL_SPEED: int = 100
@export var FRIGHTENED_SPEED: int = 40
@export var EATEN_SPEED: int = 180

@export var game: Game

var speed: int = ORIGINAL_SPEED
var temp_clone: Ghost

enum GhostState {
	SCATTER,
	CHASE,
	FRIGHTENED,
	EATEN
}

enum GhostTargeting {
	Blinky,
	Pinky,
	Inky,
	Clyde
}

var current_scatter_index: int = 0
var direction = null

var current_state: GhostState
@export var targeting: GhostTargeting
@export var blinkyGhost: Ghost

@onready var body = $Body as GhostBody
@onready var eyes = $Eyes as GhostEyes

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var scatter_timer = $ScatterTimer
@onready var chase_interval = $ChaseInterval
@onready var frightened_timer = $FrightenedTimer
@onready var score = $text/Score
 
@onready var animation_player = $AnimationPlayer

@onready var ability_cooldown = $AbilityCooldown
@onready var ability_duration = $AbilityDuration

func _ready():
	#if targeting != GhostTargeting.Inky:
		#queue_free()
	
	call_deferred("setup")
	
func _process(delta):
	if 	not frightened_timer.is_stopped() and \
	   	frightened_timer.time_left < frightened_timer.wait_time * 0.5:
			body.frighten_conclude()		
	
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
			if player.dead:
				scatter()
			
		GhostState.FRIGHTENED:
			navigation_agent_2d.target_position = tilemap.get_random_empty_cell()
			
		GhostState.EATEN:
			speed = ORIGINAL_SPEED
			
			body.show()
			scatter()
	
func setup():
	navigation_agent_2d.set_navigation_map(tilemap.get_navigation_map(0))
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), tilemap.get_navigation_map(0))
	
	scatter()

func scatter():
	chase_interval.stop()
	scatter_timer.start()
	
	ability_cooldown.stop()
	ability_duration.stop()
	
	current_state = GhostState.SCATTER
	navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position
	
	speed = ORIGINAL_SPEED
	
	body.show()
	body.move()	

func _on_scatter_timeout():
	if current_state == GhostState.SCATTER and !player.dead:
		chase()

func chase():
	current_state = GhostState.CHASE
	
	if player == null:
		print("No target. Chasing will not work")
	
	chase_interval.start()
	ability_cooldown.start()
	
	navigation_agent_2d.target_position = player.position

func _on_chase_interval_timeout():
	match targeting:
		GhostTargeting.Blinky:
			navigation_agent_2d.target_position = player.position
			
		GhostTargeting.Pinky:
			navigation_agent_2d.target_position = player.position + (player.direction * 5 * 16)
			
		GhostTargeting.Inky:
			navigation_agent_2d.target_position = player.position
			
			if abs(player.global_position - global_position) / 16 < Vector2(3, 3) && \
				randf() < 0.1 && \
				current_state == GhostState.CHASE && \
				ability_duration.is_stopped():
				
				scatter()
				
		GhostTargeting.Clyde:
			var oppositedir = (blinkyGhost.global_position - player.global_position) * -1
			navigation_agent_2d.target_position = player.global_position + (oppositedir.normalized() * 5 * 16)

func frighten():
	if current_state == GhostState.EATEN:
		return
		
	current_state = GhostState.FRIGHTENED
	
	eyes.hide()
	body.frighten()
	
	frightened_timer.start()	
	chase_interval.stop()
	
	ability_cooldown.stop()
	ability_duration.stop()
	
	if temp_clone != null:
		temp_clone.queue_free()	
	
	navigation_agent_2d.target_position = tilemap.get_random_empty_cell()
	speed = FRIGHTENED_SPEED
	
func _on_frightened_timer_timeout():
	body.move()
	eyes.show()
	
	speed = ORIGINAL_SPEED
	scatter()

func _on_body_entered(collision_body):
	if not collision_body is Player:
		return
		
	var _player = collision_body as Player
	
	if current_state == GhostState.EATEN:
		pass
	
	elif current_state == GhostState.FRIGHTENED and !player.dead:
		get_eaten()
		pass
		
	else:
		if !player.dead:
			_player.died()
			
		if targeting == GhostTargeting.Inky:
			set_collision_mask_value(3, true)
				
			navigation_agent_2d.set_navigation_layer_value(2, false)
			navigation_agent_2d.set_navigation_layer_value(1, true)

func get_eaten():
	body.hide()
	eyes.show()
	
	frightened_timer.stop()
	ability_cooldown.stop()
	ability_duration.stop()
	
	var text = Label.new()
	text.text = str(game.ghost_score_increment)
	
	game.add_child(text)
	text.global_position = global_position
	game.score_ghost()
	
	current_state = GhostState.EATEN
	speed = EATEN_SPEED
	
	navigation_agent_2d.target_position = at_home_targets[0].global_position
	
	await get_tree().create_timer(0.5).timeout
	text.queue_free()
	
func _on_ability_cooldown_timeout():	
	if current_state == GhostState.CHASE:
		match targeting:
			GhostTargeting.Blinky:
				speed *= 1.25
				body.update_color(Color.MEDIUM_VIOLET_RED)
				
			GhostTargeting.Pinky:
				body.update_color(Color.PAPAYA_WHIP)
				
			GhostTargeting.Inky:
				body.update_color(Color.STEEL_BLUE)
				
				set_collision_mask_value(3, false)
				navigation_agent_2d.set_navigation_layer_value(1, false)
				navigation_agent_2d.set_navigation_layer_value(2, true)
				
				speed *= 0.8
				
			GhostTargeting.Clyde:
				temp_clone = duplicate()
				
				game.add_child(temp_clone)
				temp_clone.global_position = tilemap.get_random_spawnable_cell()
				
		ability_duration.start()		

func _on_ability_duration_timeout():
	body.revert_color()
	
	if current_state == GhostState.CHASE:
		match targeting:
			GhostTargeting.Blinky:
				speed = ORIGINAL_SPEED
				
			GhostTargeting.Pinky:
				var new_position = tilemap.get_random_spawnable_cell()
				new_position = tilemap.get_random_spawnable_cell()
				
				global_position = new_position
				
			GhostTargeting.Inky:
				set_collision_mask_value(3, true)
				
				navigation_agent_2d.set_navigation_layer_value(2, false)
				navigation_agent_2d.set_navigation_layer_value(1, true)
				
				speed = ORIGINAL_SPEED
				
			GhostTargeting.Clyde:
				temp_clone.queue_free()
				
		ability_cooldown.start()

