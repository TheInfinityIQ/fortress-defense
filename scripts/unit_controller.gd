extends CharacterBody2D

var id: int
const movement_speed: float = 400
var animation_state: String = "idle"
var movement_type: String = "FORMATION"
var direction: String = "down"
var is_selected: bool = false
var is_moving: bool = false

const MAX_PATHING_OFFSET: int = 5
@export var goal: Vector2i = Vector2i.ZERO
@onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _selection_circle: Sprite2D = $SelectionCricle
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# TEMP
var arrow_color: Color = Color.RED
var arrow_length: float = 50.0  # Base length for the arrow
var arrow_thickness: float = 3.0
var arrowhead_size: float = 10.0

func _ready() -> void:
	_nav_agent.target_desired_distance = MAX_PATHING_OFFSET
	_nav_agent.max_speed = movement_speed

func _physics_process(delta: float) -> void:
	move()
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

func move() -> void: 
	if global_position.distance_to(goal) <= MAX_PATHING_OFFSET:
		return
	
	movement_type = determine_movement_type()
	
	if movement_type == "SIMPLE":
		simple_movement()
	elif movement_type == "COMPLEX":
		complex_movement()
	
	is_moving = true
	
	print("MT: %s" % [movement_type])
	print("Velocity: %s" % [velocity])
	move_and_slide()

func determine_movement_type() -> String:
	_raycast.target_position = to_local(goal)
	_raycast.force_raycast_update()
	if _raycast.is_colliding():
		return "COMPLEX"
	return "SIMPLE"

func simple_movement() -> void:
	var gp = global_position as Vector2i
	velocity = to_local(goal - gp).normalized() * movement_speed

func complex_movement() -> void:
	var direction: Vector2 = to_local(_nav_agent.get_next_path_position()).normalized()
	print(direction.angle())
	var collider := _raycast.get_collider()
	
	if collider is CharacterBody2D:
		var body: CollisionShape2D = collider.get_node("CollisionBody")
	print("Direction: %s\nMovemement Speed: %s" % [direction, movement_speed])
	_nav_agent.set_velocity(direction * movement_speed)
	velocity = direction * movement_speed

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

func assign_goal(new_goal: Vector2i) -> void:
	_nav_agent.target_position = new_goal
	_nav_agent.set_velocity(Vector2.ZERO)
	velocity = Vector2.ZERO

func _draw():
	draw_velocity_direction(Vector2.ZERO, velocity)
	
	if goal != null:
		var target_local = goal
		draw_line(Vector2.ZERO, target_local, Color.RED, 2)
		if _raycast.is_colliding():
			var collision_point = _raycast.get_collision_point()
			draw_line(Vector2.ZERO, collision_point, Color.YELLOW, 3)

func draw_velocity_direction(start_pos: Vector2, vel: Vector2):
	if vel.length() == 0:
		return  # Don't draw anything if velocity is zero
	# Calculate the arrow direction and length
	var direction = vel.normalized()
	var magnitude = vel.length()

	# Scale the arrow length based on velocity magnitude (optional)
	var scaled_length = min(arrow_length * (magnitude / 100.0), 100)  # Cap at 100 pixels

	# Calculate end position
	var end_pos = start_pos + direction * scaled_length

	# Draw the main arrow line
	draw_line(start_pos, end_pos, arrow_color, arrow_thickness)

	# Calculate arrowhead points
	var arrowhead_angle = PI / 6  # 30 degrees
	var arrowhead_left = end_pos + direction.rotated(PI - arrowhead_angle) * arrowhead_size
	var arrowhead_right = end_pos + direction.rotated(PI + arrowhead_angle) * arrowhead_size

	# Draw arrowhead as a triangle
	var arrowhead_points = PackedVector2Array([end_pos, arrowhead_left, arrowhead_right])
	draw_polygon(arrowhead_points, PackedColorArray([arrow_color, arrow_color, arrow_color]))

func _on_navigation_agent_2d_path_changed() -> void:
	print("NEW PATH")
