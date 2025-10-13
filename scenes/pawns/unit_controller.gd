extends CharacterBody2D

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shapecast: ShapeCast2D = $ShapeCast2D
@onready var _timer: Timer = $StuckTimer
@onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _selection_indicator: Sprite2D = $SelectionIndicator

const MOVEMENT_SPEED: int = 400

var prev_pos: Vector2 = Vector2.ZERO
var movement_type: Movement_Type = Movement_Type.SIMPLE
enum Movement_Type {COMPLEX = 1, SIMPLE = 2}
enum Direction {LEFT = 1, RIGHT = 2, UP = 3, DOWN = 4}
const Animation_Type = {
		"WALKING_DOWN" = "down_walking"
		, "WALKING_RIGHT" = "right_walking"
		, "WALKING_LEFT" = "left_walking"
		, "WALKING_UP" = "up_walking"
		, "IDLE_DOWN" = "down_idle"
		, "IDLE_UP" = "up_idle"
		, "IDLE_RIGHT" = "right_idle"
		, "IDLE_LEFT" = "left_idle"
	}
var cur_dir: Direction = Direction.DOWN
var goal: Vector2
var is_selected: bool = false

func _ready():
	_nav_agent.set_navigation_map(NavigationServer2D.get_maps()[0])

func _physics_process(delta: float) -> void:
	move()
	determine_direction()
	animate()
	determine_if_stuck()
	_shapecast.target_position = to_local(goal)

func set_goal(new_goal: Vector2) -> void:
	var maps := NavigationServer2D.get_maps()
	if maps.is_empty():
		goal = new_goal
	else:
		var nav_map := maps[0]
		if not NavigationServer2D.map_is_active(nav_map):
			NavigationServer2D.map_set_active(nav_map, true)
		goal = NavigationServer2D.map_get_closest_point(nav_map, new_goal)
	movement_type = Movement_Type.SIMPLE

func is_going_to_collide() -> bool:
	if velocity == Vector2.ZERO:
		return false
	if _shapecast.is_colliding() and global_position.distance_to(_shapecast.get_collision_point(0)) < 256:
		return true
	return false

func move() -> void:
	prev_pos = position
	match movement_type:
		Movement_Type.SIMPLE:
			move_simple()
		Movement_Type.COMPLEX:
			move_complex()
	move_and_slide()

func move_complex() -> void:
	if not goal or goal == Vector2.INF:
		return
	if is_at_goal():
		velocity = Vector2.ZERO
		return
	if not _nav_agent.target_position:
		_nav_agent.target_position = goal
	var desired_direction: Vector2 = global_position.direction_to(_nav_agent.get_next_path_position())
	velocity = desired_direction * MOVEMENT_SPEED

func move_simple() -> void:
	if not goal or goal == Vector2.INF:
		return
	if is_at_goal():
		velocity = Vector2.ZERO
		return
	var desired_direction: Vector2 = position.direction_to(goal)
	if is_going_to_collide():
		print("COLLIDING")
		desired_direction = get_steering_vector(desired_direction)
	velocity = desired_direction * MOVEMENT_SPEED

func is_at_goal() -> bool:
	return position.distance_to(goal) <= 5.0

func determine_if_stuck() -> void:
	if is_at_goal():
		_timer.stop()
		return
	if _timer.is_stopped():
		_timer.start()

func _on_stuck_timer_timeout() -> void:
	if prev_pos.distance_to(position) < 5:
		print("IS STUCK")
		movement_type = Movement_Type.COMPLEX
		_nav_agent.target_position = NavigationServer2D.map_get_closest_point(NavigationServer2D.get_maps()[0], goal)

func get_steering_vector(desired_direction: Vector2) -> Vector2:
	var tempcast: ShapeCast2D = ShapeCast2D.new()
	tempcast.position = to_local(global_position)

	var tempshape: CircleShape2D = CircleShape2D.new()
	tempshape.radius = 30
	tempcast.shape = tempshape
	add_child(tempcast)

	var max_angle: int = 90
	var angle_step: int = 45
	var steps_taken: int = 1
	var cur_angle = desired_direction.angle()
	var steer_dir: Vector2 = Vector2.ZERO
	
	# find smallest angle to steer with via looking while alternating up and down or left and right
	while steps_taken * angle_step <= max_angle:
		for sign in [-1, 1]:
			steer_dir = desired_direction.rotated(deg_to_rad(angle_step * steps_taken * sign))
			tempcast.target_position = _shapecast.target_position + steer_dir
			if not tempcast.is_colliding():
				angle_step = max_angle
				break
		steps_taken += 1
	tempcast.queue_free()
	return steer_dir

func determine_direction() -> void:
	if velocity.x < 0:
		cur_dir = Direction.LEFT
		return
	if velocity.x > 0:
		cur_dir = Direction.RIGHT
		return
	if velocity.y < 0:
		cur_dir = Direction.UP
		return
	if velocity.y > 0:
		cur_dir = Direction.DOWN
		return
	cur_dir = Direction.DOWN

func animate() -> void:
	if velocity == Vector2.ZERO:
		_animated_sprite.play(Animation_Type["IDLE_DOWN"])
		return
	
	match cur_dir:
		Direction.LEFT:
			_animated_sprite.play(Animation_Type["WALKING_LEFT"])
		Direction.RIGHT:
			_animated_sprite.play(Animation_Type["WALKING_RIGHT"])
		Direction.UP:
			_animated_sprite.play(Animation_Type["WALKING_UP"])
		Direction.DOWN:
			_animated_sprite.play(Animation_Type["WALKING_DOWN"])

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_selected = true
			enable_visibility_selection_indicator()

func select() -> void:
	enable_visibility_selection_indicator()

func enable_visibility_selection_indicator() -> void:
	_selection_indicator.visible = true

func deselect() -> void:
	_selection_indicator.visible = false
