extends KinematicBody2D

signal dead

const blood_particle = preload("res://particles/BloodParticle.tscn")

var direction = 0
var speed = 80

export(bool) var facingRight = true
export(bool) var useMovementTimer = false
export(float) var movement_timer_wait_time = 1.5

enum {
	PATROL,
	CHASE,
	RETURN
}

var state = PATROL
var velocity = Vector2.ZERO

onready var player = Global.player
onready var start_position = global_position

func _ready():
	if useMovementTimer: $MovementTimer.wait_time = movement_timer_wait_time
	if not facingRight: scale.x *= -1
	connect("dead", Global.player.get_parent().get_node("SFXPlayer"), "_on_enemy_killed")

func _physics_process(delta):
	match state:
		PATROL: patrol_state()
		
		CHASE: chase_state()
		
		RETURN: return_state()


func patrol_state():
	var rng = RandomNumberGenerator.new()
	
	while direction == 0:
		velocity = Vector2.ZERO
		rng.randomize()
		direction = rng.randi_range(-1, 1)
	
	if useMovementTimer and $MovementTimer.is_stopped(): $MovementTimer.start()
	if is_on_wall(): direction *= -1
	
	rotation_degrees = 0 if facingRight else 180
	$Sprite.flip_v = false
	velocity.y = direction * speed
	velocity = move_and_slide(velocity)


func chase_state():
	var chase_speed = speed * 2
	
	if Global.player == null:
		direction = 0
		state = PATROL
	
	var player_position = player.global_position
	look_at(player_position)
	
	if rotation_degrees > 90 or rotation_degrees < -90:
		$Sprite.flip_v = true if facingRight else false
	else:
		$Sprite.flip_v = false if facingRight else true
	
	$Sprite.scale.x = 1
	velocity = position.direction_to(player.position) * chase_speed
	velocity = move_and_slide(velocity)


func return_state():
	if position.round() - start_position.round() > Vector2(8, 8):
		look_at(start_position)
		velocity = position.direction_to(start_position) * speed
		velocity = move_and_slide(velocity)
	else:
		state = PATROL


func _on_Hurtbox_area_entered(area):
	if state != CHASE: kill()


func _on_DetectionRange_body_entered(body):
	state = CHASE


func kill():
	var blood_particle_instance = Global.instance_node(blood_particle, global_position, get_parent())
	blood_particle_instance.one_shot = true
	Global.screen_shake.start()
	emit_signal("dead")
	queue_free()


func _on_MovementTimer_timeout():
	if state == PATROL: direction *= -1


func _on_DetectionRange_body_exited(body):
	$AggroTimer.start()


func _on_AggroTimer_timeout():
	direction = 0
	state = PATROL
