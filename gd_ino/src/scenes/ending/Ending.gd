extends Node2D

## スクロール速度.
const SCROLL_SPEED = 100.0

@onready var _spr = $Sprite2D

func _ready() -> void:
	Common.play_bgm("ino2")

## 更新.
func _process(delta: float) -> void:
	
	var spd = SCROLL_SPEED * delta
	var h = _spr.texture.get_height()
	var end_y = -(h + Common.WINDOW_HEIGHT*1.3)
	
	if Input.is_action_pressed("action"):
		# 早送り.
		spd *= 20
	_spr.position.y -= spd
	
	if _spr.position.y < end_y:
		# エンディング終了.
		get_tree().change_scene_to_file("res://src/scenes/result/Result.tscn")
