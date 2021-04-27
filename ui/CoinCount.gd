extends Control

onready var coin_count = Global.coins


func _ready():
	$Label.text = str(coin_count) + "/7"

func _on_coin_collected():
	coin_count = Global.coins
	$Label.text = str(coin_count) + "/7"
