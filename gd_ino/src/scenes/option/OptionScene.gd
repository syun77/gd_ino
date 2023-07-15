extends Node2D

@onready var _bgm = $BGM/HSlider
@onready var _se = $SE/HSlider
@onready var _skip_op_ed = $CheckOpeningEnding
@onready var _retry = $CheckRetry
@onready var _lunker_support = $CheckLunkerSupport
@onready var _item_window = $CheckItemWindow

## 開始.
func _ready() -> void:
	# BGM/SE確認用.
	Common.init()
	
	_bgm.value = Common.bgm_volume
	_se.value = Common.se_volume
	_skip_op_ed.button_pressed = Common.skip_op_ed
	_retry.button_pressed = Common.quick_retry
	_item_window.button_pressed = Common.is_display_item_window
	_lunker_support.button_pressed = Common.is_lunker_support
	
	Common.play_bgm("ino2")

## タイトル画面に戻る
func _on_button_back_pressed() -> void:
	# セーブする.
	Common.to_save()
	
	Common.stop_bgm()
	get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")

## BGM音量変更.
func _on_h_slider_value_changed(value: float) -> void:
	Common.bgm_volume = value

## SE音量変更.
func _on_h_slider2_value_changed(value: float) -> void:
	if Common.playing_se("itemget2") == false:
		# 再生していなければ再生.
		Common.play_se("itemget2")
	Common.se_volume = value

## OP/EDスキップ切り替え.
func _on_check_opening_ending_toggled(b: bool) -> void:
	Common.skip_op_ed = b

## クイックリトライ変更.
func _on_check_retry_toggled(b: bool) -> void:
	Common.quick_retry = b

## ランカーモードの補助線を有効にするかどうか.
func _on_check_lunker_support_toggled(b: bool) -> void:
	Common.is_lunker_support = b

## アイテムウィンドウの表示.
func _on_check_item_window_toggled(b: bool) -> void:
	Common.is_display_item_window = b
