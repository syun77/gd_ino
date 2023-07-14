extends Control
# ===========================================
# アイテムリスト.
# ===========================================

# ----------------------------------------
# const.
# ----------------------------------------
const ITEM_PARTS_OBJ = preload("res://src/ui/UIItemParts.tscn")

# ----------------------------------------
# onready.
# ----------------------------------------
@onready var _bg = $Bg

# ----------------------------------------
# var.
# ----------------------------------------
var _item_list = {}

# ----------------------------------------
# public functions.
# ----------------------------------------
## アイテム獲得数.
func count_gain() -> int:
	var cnt = 0
	for v in _item_list.values():
		if v.gained:
			cnt += 1
	return cnt

## ゲームクリアチェック.
func is_completed() -> bool:
	var cnt = 0
	for id in Map.ITEM_LEGENDS:
		var v = _item_list[id] as UIItemParts
		if v.gained:
			cnt += 1
	
	# 3種の神器を揃えた.
	return cnt >= 3

## アイテム獲得.
func gain(itemID:Map.eItem) -> void:
	if Map.get_item_type(itemID) == Map.eItemType.POWER_UP:
		return # パワーアップ系は何もしない.
	
	var obj:UIItemParts = _item_list[itemID]
	obj.gain()

# ----------------------------------------
# private functions.
# ----------------------------------------
## 開始.
func _ready() -> void:
	# UIItemPartsをあらかじめ生成しておく.
	var pos = _bg.position
	var idx = Map.ITEM_BEGIN
	while idx <= Map.ITEM_END:
		var obj = ITEM_PARTS_OBJ.instantiate()
		obj.position = pos
		add_child(obj)
		obj.itemID = idx
		_item_list[idx] = obj
		pos.x += 16 # 一つあたりのパーツの幅.
		idx += 1
