extends Area2D

export(PackedScene) var scene

func _on_NextLevel_body_entered(body):
	get_tree().change_scene_to(scene)
