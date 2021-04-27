extends Area2D

onready var checkpoint_position = global_position


func _on_Checkpoint_body_entered(body):
	body.respawn_position = checkpoint_position
