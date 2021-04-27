extends Control

var title_screen = load("res://scenes/TitleScreen.tscn")

var coin_count = Global.coins


func _ready():
	$CoinCount.text = "You found " + str(coin_count) + "/7 coins"
	
	if coin_count == 7:
		$Final.text = "Congratulations!\nYou're a super player!"


func _input(event):
	if event is InputEventKey and event.is_pressed():
			get_tree().change_scene_to(title_screen)
