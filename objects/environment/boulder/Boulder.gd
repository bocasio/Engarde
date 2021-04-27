extends StaticBody2D

signal destroy

var rock_particle = preload("res://particles/RockParticle.tscn")


func _ready():
	connect("destroy", Global.player.get_parent().get_node("SFXPlayer"), "_on_boulder")


func _on_Hurtbox_area_entered(area):
	var rock_particle_instance = Global.instance_node(rock_particle, global_position, get_parent())
	rock_particle_instance.one_shot = true
	Global.screen_shake.start(.3, 30, 20, 1)
	emit_signal("destroy")
	queue_free()
