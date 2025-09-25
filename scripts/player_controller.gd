extends CharacterBody2D

@export var speed: float = 400
@export var zoom_multiplier: float = 1
@export var zoom_speed: float = 0.25
@export var zoom_min: Vector2 = Vector2(0.25, 0.25)
@export var zoom_max: Vector2 = Vector2(2, 2)
var _zoom_default: Vector2 = Vector2.ONE

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _camera: Camera2D = $Camera2D

var id: int
var state: String = "idle"
var direction: String = "down"
var prev_direction: String = ""
var zoom_target: Vector2 = _zoom_default
var is_moving: bool = false

var followers: Array[CharacterBody2D]
var follower_spots: Array[Node]

func _ready() -> void:
	follower_spots = $Followers.get_children()

func _physics_process(delta: float) -> void:
	$Label.text = "%sw" % [position]
	
	handle_movement(delta)
	
	handle_zoom()
	update_follower_grid()

func assign_followers(new_followers: Array[CharacterBody2D]) -> void:
	followers = new_followers

func handle_zoom() -> void:
	if Input.is_action_just_pressed("mouse_wheel_down"):
		zoom_target.x -= zoom_speed * zoom_multiplier
		zoom_target.y -= zoom_speed * zoom_multiplier
	if Input.is_action_just_pressed("mouse_wheel_up"):
		zoom_target.x += zoom_speed * zoom_multiplier
		zoom_target.y += zoom_speed * zoom_multiplier
	if Input.is_action_just_pressed("mouse_wheel_up"):
		zoom_target.x += zoom_speed * zoom_multiplier
		zoom_target.y += zoom_speed * zoom_multiplier
	
	if zoom_target < zoom_min:
		zoom_target = zoom_min
	if zoom_target > zoom_max:
		zoom_target = zoom_max
	
	_camera.zoom = _camera.zoom.cubic_interpolate(zoom_target, _camera.zoom, zoom_target, zoom_speed)

func handle_movement(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	is_moving = true if input_direction != Vector2.ZERO else false
	update_state()
	animate_movement()
	
	if not is_moving:
		return
	
	var new_dir: String = translate_vector2_to_direction(input_direction)
	update_direction(new_dir)
	velocity = input_direction * speed
	move_and_slide()

func update_state() -> void:
	if is_moving:
		state = "walking"
		return
	state = "idle"

func update_direction(new_dir: String) -> void:
	prev_direction = direction
	direction = new_dir

func translate_vector2_to_direction(vector: Vector2) -> String:
	if vector.x > 0:
		return "right"
	elif vector.x < 0:
		return "left"
	elif vector.y < 0:
		return "up"
	elif vector.y > 0:
		return "down"
	
	return "down"

func animate_movement() -> void: 
	match direction:
		"up":
			match state:
				"idle":
					_animated_sprite.play("up_idle")
				"walking":
					_animated_sprite.play("up_walking")
				_:
					_animated_sprite.play("up_idle")
		"right":
			match state:
				"idle":
					_animated_sprite.play("right_idle")
				"walking":
					_animated_sprite.play("right_walking")
				_:
					_animated_sprite.play("right_idle")
		"left":
			match state:
				"idle":
					_animated_sprite.play("left_idle")
				"walking":
					_animated_sprite.play("left_walking")
				_:
					_animated_sprite.play("left_idle")
		"down":
			match state:
				"idle":
					_animated_sprite.play("down_idle")
				"walking":
					_animated_sprite.play("down_walking")
				_:
					_animated_sprite.play("down_idle")
		_:
			_animated_sprite.play("down_idle")

func update_follower_grid() -> void:
	var index: int = 0
	var global_spot_position: Vector2i
	for follower_spot in follower_spots:
		match direction:
			"right":
				global_spot_position = global_position + Vector2(-300, 0)
			"left":
				global_spot_position = global_position + Vector2(300, 0)
			"down":
				global_spot_position = global_position + Vector2(0, -300)
			"up":
				global_spot_position = global_position + Vector2(0, 300)
		follower_spot.position = to_local(global_spot_position)
		followers[index].set_goal(global_spot_position)
		index += 1
