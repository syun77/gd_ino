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
var _gained_item = 19
var _clear_time = (59*60) + (59) + 0.999

# -----------------------------------------
# functions.
# -----------------------------------------
## 開始.
func _ready() -> void:
	_txt_item.text = "%d/%d"%[_gained_item, Map.ITEM_NUM]
	var msec = int(_clear_time*1000) % 1000
	var sec = int(_clear_time) % 60
	var minute = int(_clear_time/60)
	var time = "%2d:%02d.%03d"%[minute, sec, msec]
	_txt_time.text = time
	
	# 獲得アイテムを表示.
	var size = 64
	var pos = _item_marker.position
	pos.x -= ((10+1)/2) * size
	var p = pos
	for i in range(Map.ITEM_NUM):
		var spr = Sprite2D.new()
		spr.texture = TILE_TEXTURE
		spr.vframes = 8
		spr.hframes = 16
		spr.frame = 99
		spr.position = p
		add_child(spr)
		p.x += size
		if i % 10 == 9:
			p.x = pos.x
			p.y += size
		

## 更新.
func _physics_process(_delta: float) -> void:
	match _state:
		eState.INIT:
			_state = eState.MAIN
		eState.MAIN:
			if Input.is_action_just_released("action"):
				_state = eState.END
		eState.END:
			get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")
