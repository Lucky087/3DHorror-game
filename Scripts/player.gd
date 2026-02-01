extends CharacterBody3D

# ---------------- SPEED ----------------
var original_speed: float
var speed: float = 1.6        # horror walk
var sprint_speed: float = 2.3 # slightly faster sprint

var sprint_slider
var sprint_drain_amount := 0.3
var sprint_gain_amount := 0.12

# ---------------- CROUCH ----------------
var is_crouching := false

var stand_height: float = 1.8
var crouch_height: float = 1.0

var stand_speed: float
var crouch_speed: float = 1.4

var crouch_lerp_speed := 7.0
var stand_y := 0.0
var crouch_y := -0.4

var can_play := true

# ---------------- NODES ----------------
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var Interact_ray = $Head/Camera3D/RayCast3D
@onready var breath: AudioStreamPlayer3D = $Out_Of_Breath
# ---------------- GRAVITY ----------------
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	original_speed = speed
	stand_speed = speed
	stand_y = position.y

	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI/Sprint_slider")

func _process(delta):
	if sprint_slider == null:
		return

	if speed == sprint_speed:
		sprint_slider.value -= sprint_drain_amount * delta
		if sprint_slider.value <= sprint_slider.min_value:
			speed = original_speed

	if sprint_slider.value == sprint_slider.min_value:
		breath.play()

	if speed != sprint_speed:
		if sprint_slider.value < sprint_slider.max_value:
			sprint_slider.value += sprint_gain_amount * delta
		if sprint_slider.value >= sprint_slider.max_value:
			sprint_slider.visible = false

	if Input.is_action_just_pressed("Interact"):
		try_Interact()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Toggle crouch
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()

	update_crouch(delta)

	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if Input.is_action_just_pressed("sprint") and not is_crouching:
			sprint_slider.visible = true
			speed = sprint_speed

		if Input.is_action_just_released("sprint"):
			speed = original_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# ---------------- CROUCH FUNCTIONS ----------------
func toggle_crouch():
	if is_crouching:
		if not is_under_ceiling():
			is_crouching = false
			speed = stand_speed
	else:
		is_crouching = true
		speed = crouch_speed

func update_crouch(delta):
	var shape := collider.shape as CapsuleShape3D

	var target_height = crouch_height if is_crouching else stand_height
	var target_y = crouch_y if is_crouching else stand_y

	shape.height = lerp(shape.height, target_height, delta * crouch_lerp_speed)
	position.y = lerp(position.y, target_y, delta * crouch_lerp_speed)

func is_under_ceiling() -> bool:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = global_position + Vector3.UP * (stand_height - crouch_height)

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	return space_state.intersect_ray(query).size() > 0

# ---------------- INTERACT ----------------
func try_Interact():
	Interact_ray.force_raycast_update()

	if not Interact_ray.is_colliding():
		return

	var collider = Interact_ray.get_collider()
	if collider and collider.has_method("interact"):
		collider.interact(self)

func pickup_flashlight():
	Global.has_flashlight = true
	print("Flashlight added to inventory")
