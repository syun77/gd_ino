extends Node2D

@export var scene:PackedScene

func _ready() -> void:
	# Commonの初期化.
	Common.init()
	
	# セーブデータの読み込み.
	Common.from_load()
	
	# ゲーム開始.
	get_tree().change_scene_to_packed(scene)
