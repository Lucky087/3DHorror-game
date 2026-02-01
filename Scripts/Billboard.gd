extends Label3D

var active := false

func _ready():
	visible = false
	await get_tree().process_frame
	active = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not active:
		return
	if body.is_in_group("Player"):
		visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	visible = false
