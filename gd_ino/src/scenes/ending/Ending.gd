extends Node2D

## スクロール速度.
const SCROLL_SPEED = 100.0

@onready var _spr = $Sprite2D

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
		get_tree().change_scene_to_file("res://src/scenes/ending/Result.tscn")
