extends Node2D

## 項目リスト.
@onready var _list = $ItemList
@onready var _detail = $Detail

## 開始.
func _ready() -> void:
	# 実績確認用に初期化する.
	Common.init()
	#Achievement.unlock(Achievement.eType.ALL_COMPLETED)
	
	for id in Achievement.eType.values():
		var hbox:HBoxContainer = _list.get_child(id)
		# マウスオーバーで詳細メッセージを表示.
		var detail = Achievement.get_detail(id)
		hbox.connect("mouse_entered", func(): _detail.text = detail)
		for child in hbox.get_children():
			if child is Label:
				child.text = Achievement.get_title(id)
			elif child is TextureRect:
				if Achievement.unlocked(id) == false:
					# 未開放.
					child.texture = load("res://assets/images/achievement_icon_hatena.png")

## 戻るボタンを押した.
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")
ｓ
