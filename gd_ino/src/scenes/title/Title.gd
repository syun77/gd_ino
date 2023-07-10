extends Node2D

@onready var _menu = $Menu

## メニュー揺れタイマー.
var _timer_shake = 0.0
var _timer_shake_max = 0.0

## 更新.
func _process(delta: float) -> void:
	# release()判定で次の画面で早送りしないようにする.
	if Input.is_action_just_released("action"):
		# ゲーム開始.
		get_tree().change_scene_to_file("res://src/scenes/opening/Opening.tscn")
		return
	
	_menu.offset = Vector2.ZERO
	_timer_shake -= delta
	if _timer_shake <= 0:
		if randi()%60 < 1:
			_start_shake()
		return

	# 揺れ処理.
	var rate = _timer_shake / _timer_shake_max
	
	_menu.offset.x = randf_range(-1, 1) * 2 * rate
	_menu.offset.y = randf_range(-1, 1) * 1 * rate

## 揺れ開始.
func _start_shake() -> void:
	var t = randf_range(0.1, 0.5)
	_timer_shake = t
	_timer_shake_max = t
