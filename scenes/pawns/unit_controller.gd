extends CharacterBody2D

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shapecast: ShapeCast2D = $ShapeCast2D

const MOVEMENT_SPEED: int = 400

enum Direction {LEFT = 1, RIGHT = 2, UP = 3, DOWN = 4}
var cur_dir: Direction = Direction.DOWN
var goal: Vector2

func _physics_process(delta: float) -> void:
	move()
	determine_direction()
	animate()

func set_goal(new_goal: Vector2) -> void:
	goal = new_goal
	_shapecast.target_position = to_local(goal)

func detect_incoming_collision() -> bool:
	if velocity == Vector2.ZERO:
		return false
	return _shapecast.is_colliding()

func move() -> void:
	if not goal:
		return
	if not position.distance_to(goal) > 5:
		velocity = Vector2.ZERO
		return
	var desired_direction: Vector2 = position.direction_to(goal)
	if detect_incoming_collision():
		desired_direction = get_steering_vector(desired_direction)
	velocity = desired_direction * MOVEMENT_SPEED
	move_and_slide()

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
	
	while steps_taken * angle_step <= max_angle:
		for sign in [-1, 1]:
			steer_dir = desired_direction.rotated(deg_to_rad(angle_step * steps_taken * sign))
			tempcast.target_position = _shapecast.target_position + steer_dir
			if not tempcast.is_colliding():
				angle_step = max_angle
				break
		steps_taken += 1
	tempcast.queue_free()
	print(rad_to_deg(steer_dir.angle()))
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
	match cur_dir:
		Direction.LEFT:
			_animated_sprite.play("left_walking")
		Direction.RIGHT:
			_animated_sprite.play("right_walking")
		Direction.UP:
			_animated_sprite.play("up_walking")
		Direction.DOWN:
			_animated_sprite.play("down_walking")
