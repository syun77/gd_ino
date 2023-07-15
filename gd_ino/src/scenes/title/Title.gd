extends Node2D

## 状態.
enum eState {
	MAIN,
	END,
}

@onready var _menu = $Menu
@onready var _check_lunker = $CheckLunker
@onready var _bg = $Bg

## 状態.
var _state = eState.MAIN

## メニュー揺れタイマー.
var _timer_shake = 0.0
var _timer_shake_max = 0.0

## 開始.
func _ready() -> void:
	if Common.is_unlock_lunker_mode():
		# ランカーモードを選べる.
		_check_lunker.visible = true
		_check_lunker.button_pressed = Common.is_lunker
	_bg.visible = Common.is_lunker

## 更新.
func _process(delta: float) -> void:
	match _state:
		eState.MAIN:
			_update_main(delta)
		eState.END:
			# ボタンと同時押し問題がありそうだけどたぶん大丈夫.
			get_tree().change_scene_to_file("res://src/scenes/opening/Opening.tscn")

## 更新 > メイン.
func _update_main(delta:float) -> void:
	_bg.visible = Common.is_lunker
	if Common.is_lunker:
		_menu.frame = 0
	else:
		_menu.frame = 1
		
	# release()判定で次の画面で早送りしないようにする.
	if Input.is_action_just_released("action"):
		# ゲーム開始.
		_state = eState.END
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

## 実績.
func _on_button_achievement_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/achievement/AchievementScene.tscn")

## オプション画面.
func _on_button_option_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/option/OptionScene.tscn")

## ランカーモード切り替え.
func _on_check_lunker_toggled(b: bool) -> void:
	Common.is_lunker = b
	Common.to_save()
	# SPACEキで切り替わってしまうの、フォーカスを外す.
	_check_lunker.release_focus()
