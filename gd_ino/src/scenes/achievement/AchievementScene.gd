extends Node2D

## 項目リスト.
@onready var _list = $ItemList

## 開始.
func _ready() -> void:
	# 実績確認用に初期化する.
	Common.init()
	#Achievement.unlock(Achievement.eType.ALL_COMPLETED)
	
	for id in Achievement.eType.values():
		var label = _list.get_child(id)
		label.text = Achievement.get_title(id)
		if Achievement.unlocked(id):
			# 開放済み.
			label.text = "[✓]" + label.text

## 戻るボタンを押した.
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")
