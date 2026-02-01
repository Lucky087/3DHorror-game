extends SpotLight3D

var can_play := true

@onready var audio: AudioStreamPlayer3D = $Flashlight_Click_Sound



func _process(_float,) -> void:
	if Input.is_action_just_pressed("Flashlight") and Global.has_flashlight:
		await get_tree().create_timer(0.15).timeout
		visible = !visible
		play_sound_with_delay()

func play_sound_with_delay():
	await get_tree().create_timer(0.001).timeout  # delay in seconds
	audio.play()
	if not can_play:
		return

	can_play = false
	await get_tree().create_timer(0.001).timeout
	audio.play()
	can_play = true
