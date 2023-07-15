extends Node2D

## スクロール速度.
const SCROLL_SPEED = 100.0

@onready var _spr = $Sprite2D

func _ready() -> void:
	if Common.skip_op_ed:
		# オープニングスキップ.
		get_tree().change_scene_to_file("res://Main.tscn")
	else:
		Common.play_bgm("ino2")

## 更新.
func _process(delta: float) -> void:
	
	var spd = SCROLL_SPEED * delta
	if Input.is_action_pressed("action"):
		# 早送り.
		spd *= 20
	_spr.position.y -= spd
	
	var h = _spr.texture.get_height()
	if _spr.position.y < -(h + Common.WINDOW_HEIGHT*1.3):
		# オープニング終了.
		Common.stop_bgm()
		get_tree().change_scene_to_file("res://Main.tscn")
