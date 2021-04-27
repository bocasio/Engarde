extends Node2D

func _on_coin():
	$CoinSFX.play()


func _on_heart():
	$HeartSFX.play()


func _on_boulder():
	if not $BoulderSFX.playing: $BoulderSFX.play()


func _on_enemy_killed():
	$KillSFX.play()
