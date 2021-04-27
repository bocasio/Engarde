extends Node2D

signal fight_start
signal summon_tentacles(group)
signal next_phase
signal killed

const blood_particle = preload("res://particles/BloodParticle.tscn")
const piranha = preload("res://objects/enemies/piranha/Piranha.tscn")
const next_level = preload("res://scenes/GameOver.tscn")

var health = 4
var tentacles = 8
var group = 0

var isVulnerable = true
var isKilled = false

var blood_particle_instance


func _ready():
	connect("next_phase", get_parent(), "_on_next_phase")
	connect("fight_start", get_parent(), "_on_fight_start")
	connect("killed", get_parent(), "_on_squid_killed")
	$AnimationPlayer.play("idle")


func _process(delta):
	if isKilled:
		global_position.y += 50 * delta
		blood_particle_instance.global_position = global_position
		
		if not $AnimationPlayer.is_playing(): $AnimationPlayer.play("damage")
	else:
		pass


func _on_Hurtbox_area_entered(area):
	if isVulnerable: take_damage()


func take_damage():
	blood_particle_instance = Global.instance_node(blood_particle, global_position, get_parent())
	blood_particle_instance.scale *= 2
	$Hitbox/CollisionShape2D.disabled = true
	$AnimationPlayer.play("damage")
	isVulnerable = false
	health -= 1
	
	if health > 0:
		blood_particle_instance.one_shot = true
		group += 1
		emit_signal("summon_tentacles", group)
		$HurtSFX.play()
		$SpawnTimer.wait_time -= .5
		$SpawnTimer.start()
		$AnimationPlayer.queue("background_shift")
		$AnimationPlayer.queue("idle")
		Global.screen_shake.start()
		
		if health == 3:
			emit_signal("fight_start")
	else:
		$KillSFX.play()
		$KillTimer.start()
		Global.screen_shake.start(.5, 35, 25, 1)
		emit_signal("killed")


func _on_tentacle_destroyed():
	tentacles -= 1
	if tentacles == 6 or tentacles == 4 or tentacles == 0:
		$PhaseTimer.start()


func next_phase():
	emit_signal("next_phase")
	$AnimationPlayer.play("foreground_shift")
	$AnimationPlayer.queue("idle")
	$Hitbox/CollisionShape2D.disabled = false
	isVulnerable = true


func _on_PhaseTimer_timeout():
	next_phase()


func _on_SpawnTimer_timeout():
	if health > 0:
		var piranha_instance = Global.instance_node(piranha, global_position + Vector2(0, rand_range(-100, 100)), get_parent().get_node("Piranhas"))
		$SpawnTimer.start()


func _on_KillTimer_timeout():
	kill()


func kill():
	isKilled = true
	$NextSceneTimer.start()


func _on_NextSceneTimer_timeout():
	get_tree().change_scene_to(next_level)
