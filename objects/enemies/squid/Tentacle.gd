extends Node2D

signal destroyed

const blood_particle = preload("res://particles/BloodParticle.tscn")

export var speed = 150
var direction = Vector2.ZERO

var isDestroyed = false

export(int) var tentacle_group = 1

export(bool) var up = false
export(bool) var down = false
export(bool) var left = false
export(bool) var right = false

onready var squid = get_parent().get_node("Squid")


func _ready():
	if up: direction = Vector2(0, -1)
	if down: direction = Vector2(0, 1)
	if left: direction = Vector2(-1, 0)
	if right: direction = Vector2(1, 0)
	
	$AnimationPlayer.play("idle")
	squid.connect("summon_tentacles", self, "_on_tentacle_summoned")
	connect("destroyed", squid, "_on_tentacle_destroyed")
	set_process(false)


func _process(delta):
	global_position += speed * direction * delta


func _on_tentacle_summoned(group):
	if tentacle_group == group:
		set_process(true)


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("player_hitbox") and not isDestroyed:
		var blood_particle_instance = Global.instance_node(blood_particle, $Hurtbox/CollisionShape2D.global_position, get_parent())
		blood_particle_instance.one_shot = true
		blood_particle_instance.scale *= 2
		direction *= -1
		$Hitbox.queue_free()
		$DestroyTimer.start()
		$HurtSFX.play()
		Global.screen_shake.start()
		emit_signal("destroyed")
		set_process(true)
		isDestroyed = true


func _on_DestroyTimer_timeout():
	queue_free()
