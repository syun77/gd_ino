extends Node2D
# =========================================
# リザルト画面.
# =========================================
# -----------------------------------------
# const.
# -----------------------------------------
const TILE_TEXTURE = preload("res://assets/tiles/tile.png")

enum eState {
	INIT,
	MAIN,
	END,
}

# -----------------------------------------
# onready.
# -----------------------------------------
@onready var _txt_item = $GainItem
@onready var _txt_time = $ClearTime
@onready var _item_marker = $ItemMarker

# -----------------------------------------
# var.
# -----------------------------------------
var _state = eState.INIT
var _gained_item = 0
var _clear_time = (59*60) + (59) + 0.999

# -----------------------------------------
# functions.
# -----------------------------------------
## 開始.
func _ready() -> void:
	# クリア時間.
	_clear_time = Common.get_past_time()
	_txt_time.text = Common.get_past_time_str()
	
	# 獲得アイテムを表示.
	var size = 64
	var pos = _item_marker.position
	pos.x -= ((10-0.5)/2) * size
	var p = pos
	var idx = 0
	for id in range(Map.ITEM_BEGIN, Map.ITEM_END + 1):
		var spr = Sprite2D.new()
		spr.texture = TILE_TEXTURE
		spr.vframes = 8
		spr.hframes = 16
		spr.frame = Map.ITEM_UNKNOWN
		if Common.has_item(id):
			# 獲得済み.
			_gained_item += 1
			spr.frame = Item.SPR_FRAME_OFS + id - 1
		spr.position = p
		add_child(spr)
		p.x += size
		if idx % 10 == 9:
			p.x = pos.x
			p.y += size
		idx += 1
	
	# 獲得アイテム数を表示.
	_txt_item.text = "%d/%d"%[_gained_item, Map.ITEM_NUM]
	
	# 実績チェック.
	UiOverlay.check_all_achievements()
	
	# セーブ.
	Common.to_save()
	
## 更新.
func _physics_process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Common.stop_bgm()
	get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")
