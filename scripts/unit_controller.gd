extends CharacterBody2D

var id: int
const movement_speed: float = 20000
var animation_state: String = "idle"
var movement_state: String = "FORMATION"
var direction: String = "down"
var is_selected: bool = false
var is_moving: bool = false

const MAX_PATHING_OFFSET: int = 5
@export var goal: Node2D = null
@onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _selection_circle: Sprite2D = $SelectionCricle
@onready var _raycast: RayCast2D = $RayCast2D

func _ready() -> void:
	_nav_agent.target_desired_distance = MAX_PATHING_OFFSET

func _physics_process(delta: float) -> void:
	_on_navigation_agent_2d_velocity_computed(move(delta))
	animate_movement()
	queue_redraw()
	
	if is_selected:
		_selection_circle.visible = true
	else:
		_selection_circle.visible = false

func _on_selection_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouse_primary"):
		is_selected = true

func _on_target_reached() -> void:
	is_moving = false

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	pass # Replace with function body.

func determine_movement_type() -> String:
	_raycast.target_position = to_local(goal.global_position)
	_raycast.force_raycast_update()
	if _raycast.is_colliding():
		return "COMPLEX"
	return "SIMPLE"

func move(delta: float) -> Vector2: 
	if global_position.distance_to(goal.global_position) <= MAX_PATHING_OFFSET:
		return Vector2.ZERO
	var target_direction: Vector2 = Vector2.ZERO
	movement_state = determine_movement_type()
	
	if movement_state == "SIMPLE":
		target_direction = simple_movement()
	elif movement_state == "COMPLEX":
		target_direction = complex_movement()
	
	is_moving = true
	
	update_direction(target_direction)
	velocity = target_direction * movement_speed * delta
	move_and_slide()
	
	return velocity

func simple_movement() -> Vector2:
	#print("Simple")
	return to_local(goal.global_position).normalized()

func complex_movement() -> Vector2:
	#print("Complex")
	return to_local(_nav_agent.get_next_path_position()).normalized()

func update_direction(new_dir: Vector2) -> void:
	if new_dir == Vector2.ZERO:
		return
	
	if new_dir.x > 0:
		direction = "right"
	elif new_dir.x < 0:
		direction = "left"
	elif new_dir.y < 0:
		direction = "up"
	elif new_dir.y > 0:
		direction = "down"

func animate_movement() -> void:
	match direction:
		"up":
			match animation_state:
				"idle":
					_animated_sprite.play("up_idle")
				"walking":
					_animated_sprite.play("up_walking")
				_:
					_animated_sprite.play("up_idle")
		"right":
			match animation_state:
				"idle":
					_animated_sprite.play("right_idle")
				"walking":
					_animated_sprite.play("right_walking")
				_:
					_animated_sprite.play("right_idle")
		"left":
			match animation_state:
				"idle":
					_animated_sprite.play("left_idle")
				"walking":
					_animated_sprite.play("left_walking")
				_:
					_animated_sprite.play("left_idle")
		"down":
			match animation_state:
				"idle":
					_animated_sprite.play("down_idle")
				"walking":
					_animated_sprite.play("down_walking")
				_:
					_animated_sprite.play("down_idle")
		_:
			_animated_sprite.play("down_idle")

func assign_goal(new_goal: Node2D) -> void:
	goal = new_goal
	_nav_agent.target_position = new_goal.global_position

func _draw():
	if goal != null:
		var target_local = to_local(goal.global_position)
		draw_line(Vector2.ZERO, target_local, Color.RED, 2)
		if _raycast.is_colliding():
			var collision_point = to_local(_raycast.get_collision_point())
			draw_line(Vector2.ZERO, collision_point, Color.YELLOW, 3)
