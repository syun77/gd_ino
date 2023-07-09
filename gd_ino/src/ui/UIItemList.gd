extends Control

const ITEM_PARTS_OBJ = preload("res://src/ui/UIItemParts.tscn")

@onready var _bg = $Bg

var _item_list = {}

func gain(itemID:Map.eItem) -> void:
	if Map.get_item_type(itemID) == Map.eItemType.POWER_UP:
		return # パワーアップ系は何もしない.
	
	var obj:UIItemParts = _item_list[itemID]
	obj.gain()

func _ready() -> void:
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
