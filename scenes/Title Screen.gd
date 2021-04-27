extends Control

const next_scene = preload("res://scenes/LevelOne.tscn")


func _input(event):
	if event is InputEventKey and event.is_pressed():
		Global.coins = 0
		get_tree().change_scene_to(next_scene)
