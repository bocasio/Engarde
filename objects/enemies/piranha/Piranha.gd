extends KinematicBody2D

signal dead

const blood_particle = preload("res://particles/BloodParticle.tscn")

var direction = 0
var speed = 50

enum {
	PATROL,
	CHASE
}

var state = PATROL
var velocity = Vector2.ZERO

onready var player = Global.player


func _ready():
	if Global.player != null:
		connect("dead", Global.player.get_parent().get_node("SFXPlayer"), "_on_enemy_killed")


func _physics_process(delta):
	match state:
		PATROL: patrol_state()
		
		CHASE: chase_state()


func patrol_state():
	var rng = RandomNumberGenerator.new()
	
	while direction == 0:
		velocity = Vector2.ZERO
		rng.randomize()
		direction = rng.randi_range(-1, 1)
	
	if is_on_wall(): direction *= -1
	
	$Sprite.scale.x = -1 if direction == -1 else 1
	$Sprite.flip_v = false
	rotation_degrees = 0
	velocity.x = direction * speed
	velocity = move_and_slide(velocity)


func chase_state():
	var chase_speed = speed * 2
	
	if Global.player == null:
		direction = 0
		state = PATROL
	else:
		var player_position = Global.player.global_position
		look_at(player_position)
		
		if rotation_degrees > 90 or rotation_degrees < -90:
			$Sprite.flip_v = true
		else:
			$Sprite.flip_v = false
		
		$Sprite.scale.x = 1
		velocity = position.direction_to(Global.player.position) * chase_speed
		velocity = move_and_slide(velocity)


func _on_Hurtbox_area_entered(area):
	if not area.is_in_group("boss"):
		kill()


func _on_DetectionRange_body_entered(body):
	state = CHASE


func kill():
	var blood_particle_instance = Global.instance_node(blood_particle, global_position, get_parent())
	blood_particle_instance.one_shot = true
	Global.screen_shake.start()
	emit_signal("dead")
	queue_free()
