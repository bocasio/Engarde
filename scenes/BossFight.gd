extends Node2D

onready var player = Global.player
onready var bubble1 = $ItemBubble
onready var bubble2 = $ItemBubble2

var phase = 0


func _ready():
	player.connect("killed", self, "_on_player_killed")
	bubble1.set_process(false)
	bubble2.set_process(false)


func _on_next_phase():
	phase += 1
	
	if phase == 1:
		bubble1.set_process(true)
		bubble1.isTriggered = true
	elif phase == 2:
		bubble2.set_process(true)
		bubble2.isTriggered = true
	else:
		pass


func _on_player_killed():
	$RespawnTimer.start()


func _on_RespawnTimer_timeout():
	get_tree().reload_current_scene()


func _on_fight_start():
	if $Control/Label.visible == true: $TextTimer.start()


func _on_TextTimer_timeout():
	$Control/Label.visible = false


func _on_squid_killed():
	for piranha_instance in $Piranhas.get_children():
		piranha_instance.kill()
