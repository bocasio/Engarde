extends Area2D

func _on_TentacleStopper_area_entered(area):
	if not area.is_in_group("enemy"):
		area.get_parent().set_process(false)
		queue_free()
