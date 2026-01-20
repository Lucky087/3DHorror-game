extends SpotLight3D

func _process(_float) -> void:
	if Input.is_action_just_pressed("Flashlight"):
		visible = !visible
