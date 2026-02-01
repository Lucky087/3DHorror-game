extends Node3D

func interact(player):
	if Input.is_action_just_pressed("Interact"):
		print("Picked up flashlight")

	# Example: give flashlight to player
		if player.has_method("pickup_flashlight"):
			player.pickup_flashlight()

		queue_free() # remove flashlight from world
