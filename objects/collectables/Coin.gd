extends Node2D

signal destroy


func _ready():
	connect("destroy", Global.player.get_parent().get_node("SFXPlayer"), "_on_coin")


func _on_Hitbox_body_entered(body):
	Global.coins += 1
	body.emit_signal("coin_collected")
	emit_signal("destroy")
	queue_free()
