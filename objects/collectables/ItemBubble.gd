extends Node2D

const bubble_particle = preload("res://particles/BubbleParticle.tscn")

export(PackedScene) var item_scene
export(int) var speed = 25
export(float) var movement_timer = .5

var velocity = Vector2(1, -1)
var isTriggered = false

func _ready():
	var item_instance = item_scene.instance()
	var item_texture = item_instance.get_node("Sprite").texture
	
	$Sprite/ItemSprite.texture = item_texture
	$MovementTimer.wait_time = movement_timer


func _process(delta):
	if $VisibilityNotifier2D.is_on_screen() and isTriggered == false:
		isTriggered = true
	
	if isTriggered:
		global_position += speed * velocity * delta


func _on_Hitbox_area_entered(area):
	if not area.is_in_group("boss"):
		var bubble_particle_instance = Global.instance_node(bubble_particle, global_position, get_parent())
		
		bubble_particle_instance.one_shot = true
		Global.instance_node(item_scene, global_position, get_parent())
		queue_free()
	


func _on_MovementTimer_timeout():
	velocity.x *= -1
