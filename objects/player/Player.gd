extends KinematicBody2D

signal health_updated(health)
signal coin_collected()
signal killed()

const MAX_SPEED = 300 / 1.5
const ACCELERATION = 150 / 1.5
const FRICTION = 75 / 1.5
const ATTACK_SPEED = 330

const bubble_particle = preload("res://particles/BubbleParticle.tscn")
const trail_particle = preload("res://particles/TrailParticle.tscn")
const blood_particle = preload("res://particles/BloodParticle.tscn")

enum {
	MOVE,
	ATTACK,
	DEAD
}

var state = MOVE
var velocity = Vector2.ZERO
var attack_direction = Vector2(1, 0)
var max_health = 3

onready var health = max_health setget _set_health
onready var respawn_position = global_position


func _ready():
	connect("health_updated", get_parent().get_node("UI/HealthBar"), "_on_player_health_updated")
	connect("coin_collected", get_parent().get_node("UI/CoinCount"), "_on_coin_collected")
	emit_signal("health_updated", max_health)
	
	Global.player = self
	Global.camera = $Camera2D
	Global.screen_shake = $Camera2D/ScreenShake


func _exit_tree():
	Global.player = null


func _physics_process(delta):
	match state:
		MOVE: move_state(delta)
		
		ATTACK: attack_state(delta)
		
		DEAD: dead_state(delta)


func move():
	velocity = move_and_slide(velocity)

func attack():
	$AttackCooldown.start()
	$AnimationPlayer.play("Attack")
	var bubble_particle_instance = Global.instance_node(bubble_particle, $Hitbox/CollisionShape2D.global_position, get_parent())
	bubble_particle_instance.one_shot = true
	state = ATTACK


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_vector.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	look_at(get_global_mouse_position())
	
	if rotation_degrees > 90 or rotation_degrees < -90:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false
	
	move()
	
	if Input.is_action_just_pressed("attack"):
		$AttackSFX.play()
		attack()
	
	if health == 0: state = DEAD


func attack_state(delta):
	velocity = attack_direction.rotated(rotation) * ATTACK_SPEED
	var trail_particle_instance = Global.instance_node(trail_particle, global_position, get_parent())
	trail_particle_instance.one_shot = true
	trail_particle_instance.rotation_degrees = rotation_degrees
	move()
	
	if health == 0: state = DEAD


func dead_state(delta):
	Global.player = null
	$Sprite.visible = false
	$Hitbox/CollisionShape2D.disabled = true
	velocity = Vector2.ZERO
	
	if $RespawnTimer.is_stopped():
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.stop(true)
		$Sprite.scale = Vector2(1, 1)
		var blood_particle_instance = Global.instance_node(blood_particle, global_position, get_parent())
		blood_particle_instance.one_shot = true
		$RespawnTimer.start()
		emit_signal("killed")


func _on_AttackCooldown_timeout():
	velocity /= 2.5
	state = MOVE


func _on_Hurtbox_area_entered(area):
	if area.get_node("CollisionShape2D").disabled == false and state != DEAD:
		damage(1)


func damage(amount):
	if $InvincibilityTimer.is_stopped() and state != DEAD:
		$InvincibilityTimer.start()
		velocity = Vector2(0, -1).rotated(rotation) * 200
		_set_health(health - amount)
		Global.screen_shake.start()
		$AnimationPlayer.queue("damage")
		$AnimationPlayer.queue("flash")
		$HurtSFX.play()


func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	
	if health != prev_health:
		emit_signal("health_updated", health)
		
		if health == 0 and state != DEAD:
			$DeathSFX.play()
			velocity = Vector2.ZERO
			state = DEAD


func _on_RespawnTimer_timeout():
	respawn()


func respawn():
	Global.player = self
	_set_health(max_health)
	$Sprite.visible = true
	$Hitbox/CollisionShape2D.disabled = false
	global_position = respawn_position
	state = MOVE
