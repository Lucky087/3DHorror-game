extends CharacterBody3D

var original_speed: float
var speed = 2.0
var sprint_speed = 4.0
var sprint_slider
var sprint_drain_amount = 0.3
var sprint_gain_amount = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	original_speed = speed
	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI/Sprint_slider")

func _process(delta):
	if sprint_slider == null:
		return

	if speed == sprint_speed:
		sprint_slider.value = sprint_slider.value - sprint_drain_amount * delta
		if sprint_slider.value == sprint_slider.min_value:
			speed = original_speed
	if speed != sprint_speed:
		if sprint_slider.value < sprint_slider.max_value:
			sprint_slider.value = sprint_slider.value + sprint_gain_amount * delta
		if sprint_slider.value == sprint_slider.max_value:
			sprint_slider.visible = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_just_pressed("sprint"):
			sprint_slider.visible = true
			speed = sprint_speed
		if Input.is_action_just_released("sprint"):
			speed = original_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
