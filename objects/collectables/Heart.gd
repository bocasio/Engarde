extends Node2D

signal destroy


func _ready():
	connect("destroy", Global.player.get_parent().get_node("SFXPlayer"), "_on_heart")


func _on_Hitbox_body_entered(body):
	body._set_health(body.health + 1)
	emit_signal("destroy")
	queue_free()
