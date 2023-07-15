extends Control

# ========================================
# アイテム獲得UI
# ========================================
class_name UIItem

# ----------------------------------------
# const.
# ----------------------------------------
const TIME_WAIT = 0.1

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
func setup(itemID:Map.eItem, se:AudioStreamPlayer) -> void:
	_itemID = itemID
	
	if Item.is_special(itemID):
		# 特殊アイテム.
		se.stream = load(Common.get_se_path("itemget"))
	else:
		se.stream = load(Common.get_se_path("itemget2"))
	se.play()

# ----------------------------------------
# private functions.
# ----------------------------------------
## 開始.
func _ready() -> void:
	_item.frame = Item.SPR_FRAME_OFS + _itemID - 1
	_window.frame = _itemID - 1
	
	_frame.color = Map.item_to_color(_itemID)
	_root.position.y = -1024

## 更新.	
func _physics_process(delta: float) -> void:
	_timer += delta
	
	_root.position.y *= 0.8
	
	if _timer < TIME_WAIT:
		return
		
	if Input.is_action_just_pressed("action"):
		# 閉じる.
		queue_free()
