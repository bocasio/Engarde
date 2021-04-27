extends Control

var heart_size = 17


func _on_player_health_updated(player_health):
	$Heart.rect_size.x = player_health * heart_size
	
	visible = false if player_health == 0 else true
