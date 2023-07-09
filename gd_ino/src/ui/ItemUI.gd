extends Control

# ========================================
# アイテムUI
# ========================================
class_name ItemUI

# ----------------------------------------
# const.
# ----------------------------------------
const TIME_WAIT = 0.5

# ----------------------------------------
# onready.
# ----------------------------------------
@onready var _root = $Root
@onready var _frame = $Root/Frame
@onready var _item = $Root/Item
@onready var _window = $Root/Window

# ----------------------------------------
# var.
# ----------------------------------------
var _itemID = Map.eItem.NONE
var _timer = 0.0

# ----------------------------------------
# public functions.
# ----------------------------------------
func setup(itemID:Map.eItem) -> void:
	_itemID = itemID
	_item.frame = Item.SPR_FRAME_OFS + _itemID - 1
	_window.frame = _itemID - 1
	
	if Item.is_rare(itemID):
		# レアアイテム.
		Common.play_se("itemget")
	else:
		Common.play_se("itemget2")
	
	_root.position.y = -1024

# ----------------------------------------
# private functions.
# ----------------------------------------
func _physics_process(delta: float) -> void:
	_timer += delta
	
	_root.position.y *= 0.8
	
	if _timer < TIME_WAIT:
		return
		
	if Input.is_action_just_pressed("action"):
		# 閉じる.
		queue_free()
